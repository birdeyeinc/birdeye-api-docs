#!/usr/bin/env ruby
# frozen_string_literal: true

# Audits an API Blueprint-to-OpenAPI migration for endpoint coverage and the
# content that Mintlify renders from the OpenAPI document. Uses only Ruby's
# standard library so it can run in CI without installing extra dependencies.

require 'date'
require 'json'
require 'yaml'

HTTP_METHODS = %w[get post put delete patch].freeze
APIB_TYPE_PATTERN = /\((?:[^)]*,\s*)?(?:object|array(?:\[[^\]]+\])?|number|string(?:\[\])?|boolean|integer)(?:\s*,[^)]*)?\)/i
STATIC_PAGE_TITLES = {
  'introduction' => 'Introduction',
  'authentication' => 'Authentication and Rate limiting',
  'pagination' => 'Pagination',
  'http-status-codes' => 'HTTP Status Codes',
  'error-response' => 'Error Response'
}.freeze
GROUP_PAGE_PATHS = {
  'Business' => 'api/business/overview',
  'Custom Fields' => 'api/custom-fields/overview',
  'User' => 'api/user/overview',
  'Reviews' => 'api/reviews/overview',
  'Contact' => 'api/contact/overview',
  'Contact V2' => 'api/contact-v2/overview',
  'Campaign' => 'api/campaign/overview',
  'Aggregation' => 'api/aggregation/overview',
  'Report' => 'api/report/overview',
  'Survey' => 'api/survey/overview',
  'Business Media' => 'api/business-media/overview',
  'Social' => 'api/social/overview',
  'Conversation' => 'api/conversation/overview',
  'Subscription' => 'api/subscription/overview',
  'Webhook' => 'api/webhook/overview',
  'Competitor' => 'api/competitor/overview',
  'Competitor AI' => 'api/competitor-ai/overview',
  'Insight AI' => 'api/insight-ai/overview',
  'Google Q&A' => 'api/google-q-a/overview',
  'Google Services' => 'api/google-services/overview',
  'FAQ' => 'api/faq/overview',
  'Listing' => 'api/listing/overview',
  'GMB Products' => 'api/gmb-products/overview',
  'Search AI' => 'api/search-ai/overview',
  'Ticketing' => 'api/ticketing/overview',
  'Integration' => 'api/integration/overview'
}.freeze

def usage!
  warn 'Usage: ruby tools/audit_apib_migration.rb [--sync-examples] path/to/apiary.apib api/openapi.yaml'
  exit 2
end

def normalize_path(path)
  path = path.sub(/\{\?[^}]+\}\z/, '')
  path = path.sub(/\?\{\?[^}]+\}\z/, '?')
  path
end

def normalize_response_status(status)
  status.match?(/\A[1-5]\d\d\z/) ? status : '400'
end

def deep_copy(value)
  Marshal.load(Marshal.dump(value))
end

def leading_spaces(line)
  line[/\A */].length
end

def parse_field(line)
  match = line.match(/\A\s*\+\s+(.+?)\s*\z/)
  return unless match

  value = match[1]
  return if value.start_with?('(', '`')

  type_match = value.match(APIB_TYPE_PATTERN)
  colon_index = value.index(':')
  name = if colon_index && (!type_match || colon_index < type_match.begin(0))
           value[0...colon_index]
         elsif type_match
           value[0...type_match.begin(0)]
         else
           value[/\A(.+?)\s+-\s+/, 1]
         end
  return unless name

  name = name.strip
  return if name.empty? || name.include?(' ')

  name
end

def field_description(line)
  name = parse_field(line)
  return unless name

  value = line.match(/\A\s*\+\s+(.+?)\s*\z/)[1]
  type_match = value.match(APIB_TYPE_PATTERN)
  suffix = if type_match
             value[type_match.end(0)..].to_s.strip
           else
             value[name.length..].to_s.strip
           end
  description = if type_match
                  suffix.match?(/\A[-:]/) ? suffix.sub(/\A[-:]\s*/, '') : suffix
                elsif (separator = suffix.index(' - '))
                  suffix[(separator + 3)..]
                elsif suffix.start_with?('-')
                  suffix.sub(/\A-\s*/, '')
                end
  description&.strip
end

def field_metadata(line)
  value = line.match(/\A\s*\+\s+(.+?)\s*\z/)&.[](1)
  return {} unless value

  name = parse_field(line)
  return {} unless name

  type_match = value.match(APIB_TYPE_PATTERN)
  type = if type_match
           token = type_match[0].match(/array(?:\[[^\]]+\])?|string\[\]|object|number|string|boolean|integer/i)&.[](0)&.downcase
           token&.start_with?('array', 'string[]') ? 'array' : token
         end
  requirement = if type_match&.[](0)&.match?(/\brequired\b/i)
                  true
                elsif type_match&.[](0)&.match?(/\boptional\b/i)
                  false
                end
  colon_index = value.index(':')
  example = if colon_index && (!type_match || colon_index < type_match.begin(0))
              ending = type_match ? type_match.begin(0) : (value.index(' - ', colon_index) || value.length)
              value[(colon_index + 1)...ending].strip
            end
  { type: type, required: requirement, example: example }
end

def normalized_field_description(value)
  value.to_s.gsub(/\s+/, ' ').strip
end

def attribute_paths(lines, start_index)
  heading_indent = leading_spaces(lines[start_index])
  root_is_array = lines[start_index].include?('(array)')
  entries = []
  index = start_index + 1

  while index < lines.length
    line = lines[index]
    break if line.match?(/^#{' ' * heading_indent}\+ (?:Body|Headers|Request|Response|Parameters)\b/)
    break if line.match?(/^#{' ' * [heading_indent - 4, 0].max}\+ (?:Request|Response)\b/)
    break if line.match?(/^\#{1,3} /)

    if line.match?(/^\s*\+ /) && leading_spaces(line) > heading_indent
      entries << [leading_spaces(line), parse_field(line), field_description(line), field_metadata(line)]
    end
    index += 1
  end

  paths = []
  descriptions = {}
  metadata = {}
  stack = []
  entries.each do |indent, field, description, field_data|
    next unless field

    stack.pop while stack.any? && stack.last[0] >= indent
    parent_names = stack.map { |entry| entry[1] }
    path = ([root_is_array ? '[]' : nil] + parent_names + [field]).compact.join('.')
    paths << path
    descriptions[path] = description if description && !description.empty?
    metadata[path] = field_data
    stack << [indent, field]
  end
  [paths.uniq, descriptions, metadata, index]
end

def json_body(lines, start_index)
  index = start_index + 1
  body_lines = []

  while index < lines.length
    line = lines[index]
    break if line.match?(/^\s{0,4}\+ (?:Headers|Attributes|Body|Request|Response|Parameters)\b/)
    break if line.match?(/^\#{1,3} /)

    body_lines << line
    index += 1
  end

  body_lines.shift while body_lines.first&.strip&.empty?
  body_lines.pop while body_lines.last&.strip&.empty?
  return [nil, index] if body_lines.empty?

  indentation = body_lines.reject { |line| line.strip.empty? }.map { |line| leading_spaces(line) }.min || 0
  body = body_lines.map { |line| line.strip.empty? ? "\n" : line[indentation..] }.join.strip
  [JSON.parse(body), index]
rescue JSON::ParserError
  [nil, index]
end

def parse_apib(file)
  lines = File.readlines(file, encoding: 'UTF-8')
  operations = []
  group = nil
  resource = nil
  index = 0

  while index < lines.length
    line = lines[index]
    if (match = line.match(/^# Group (.+)/))
      group = match[1].strip
      resource = nil
    elsif group && group != 'Change Logs' && (match = line.match(/^## (.+?) \[(.+)\]\s*$/))
      resource = {
        title: match[1].strip,
        path: match[2].strip,
        line: index + 1,
        description_lines: []
      }
    elsif resource && (match = line.match(/^### (.+?)\s*\[(GET|POST|PUT|DELETE|PATCH)(?:\s+[^\]]+)?\]\s*$/))
      description = resource[:description_lines].join.strip
      operation = {
        group: group,
        resource: resource[:title],
        summary: match[1].strip,
        method: match[2].downcase,
        path: normalize_path(resource[:path]),
        source_path: resource[:path],
        source_line: resource[:line],
        description: description,
        parameters: [],
        parameter_descriptions: {},
        parameter_metadata: {},
        headers: [],
        request_paths: [],
        request_descriptions: {},
        request_metadata: {},
        request_media_type: nil,
        request_example: nil,
        response_statuses: [],
        response_examples: {},
        response_refs: Hash.new { |hash, key| hash[key] = [] },
        response_descriptions: Hash.new { |hash, key| hash[key] = {} },
        response_metadata: Hash.new { |hash, key| hash[key] = {} },
        response_paths: Hash.new { |hash, key| hash[key] = [] }
      }
      operations << operation

      context = nil
      section = nil
      status = nil
      last_parameter = nil
      preamble_lines = []
      index += 1
      while index < lines.length && !lines[index].match?(/^\#{1,3} /)
        current = lines[index]
        if (request = current.match(/^\s{0,4}\+ Request(?: \(([^)]+)\))?/))
          context = :request
          section = nil
          status = nil
          operation[:request_media_type] = request[1]
        elsif (response = current.match(/^\s{0,4}\+ Response (\d+)/))
          context = :response
          section = nil
          status = normalize_response_status(response[1])
          operation[:response_statuses] << status
        elsif current.match?(/^\s{0,4}\+ Parameters\b/)
          section = :parameters
          status = nil
          last_parameter = nil
        elsif current.match?(/^\s{4}\+ Headers\b/)
          section = :headers
        elsif current.match?(/^\s{4}\+ Body\b/)
          example, next_index = json_body(lines, index)
          if context == :request
            operation[:request_example] = example unless example.nil?
          elsif context == :response && status&.match?(/\A[1-5]\d\d\z/)
            operation[:response_examples][status] = example unless example.nil?
          end
          section = :body
          index = next_index - 1
        elsif current.match?(/^\s{3,4}\+ Attributes\b/)
          paths, descriptions, metadata, next_index = attribute_paths(lines, index)
          if context == :request
            operation[:request_paths].concat(paths)
            operation[:request_descriptions].merge!(descriptions)
            operation[:request_metadata].merge!(metadata)
          elsif context == :response && status
            operation[:response_paths][status].concat(paths)
            operation[:response_descriptions][status].merge!(descriptions)
            operation[:response_metadata][status].merge!(metadata)
          end
          section = :attributes
          index = next_index - 1
        elsif section == :parameters && (field = parse_field(current))
          operation[:parameters] << field
          description = field_description(current)
          operation[:parameter_descriptions][field] = description if description && !description.empty?
          operation[:parameter_metadata][field] = field_metadata(current)
          last_parameter = field
        elsif section == :parameters && last_parameter && !current.strip.empty?
          operation[:parameter_descriptions][last_parameter] = [
            operation[:parameter_descriptions][last_parameter],
            current.strip
          ].compact.join("\n")
        elsif section == :headers && (header = current.match(/^\s{8,}([^:]+):\s*(.+?)\s*$/))
          operation[:headers] << [header[1].strip, header[2].strip]
        elsif context == :response && status && (reference = current.match(/^\s+\[(\d+)\]\[\]\s*$/))
          operation[:response_refs][status] << reference[1]
        elsif context.nil? && section.nil?
          preamble_lines << current
        end
        index += 1
      end
      preamble = preamble_lines.join.strip
      operation[:description] = [operation[:description], preamble].reject(&:empty?).join("\n\n")
      next
    elsif resource
      resource[:description_lines] << line
    end
    index += 1
  end

  operations
end

def normalized_content(value)
  value.to_s.lines.map(&:rstrip).reject { |line| line.empty? }.join("\n").strip
end

def normalized_visible_content(value)
  value.to_s.lines.map(&:rstrip).reject do |line|
    line.empty? || line.match?(/\A(?:<pre><code>|<\/pre><\/code>|```\w*)\z/)
  end.join("\n").strip
end

def mdx_frontmatter(content)
  content[/\A---\s*\n(.*?)\n---\s*\n/m, 1].to_s
end

def mdx_body(path)
  File.read(path).sub(/\A---\s*\n.*?\n---\s*\n/m, '').strip
end

def mdx_title(path)
  frontmatter = mdx_frontmatter(File.read(path))
  match = frontmatter.match(/^title:\s*["']?(.+?)["']?\s*$/)
  match && match[1]
end

def parse_apib_document(file)
  lines = File.readlines(file, encoding: 'UTF-8')
  title_index = lines.index { |line| line.match?(/^# Birdeye\s*$/) }
  first_model_index = lines.index { |line| line.match?(/^## \d+ \[\/\d+\]\s*$/) }
  overview = if title_index && first_model_index
               lines[(title_index + 1)...first_model_index].join.strip
             else
               ''
             end

  section_headings = [
    ['authentication', /^### Authentication and Rate limiting\s*$/],
    ['pagination', /^### Pagination\s*$/],
    ['http-status-codes', /^### HTTP Status Codes\s*$/],
    ['error-response', /^### Error Response\s*$/]
  ]
  heading_indices = section_headings.map do |name, pattern|
    [name, lines.index { |line| line.match?(pattern) }]
  end
  sections = {}
  authentication_index = heading_indices.assoc('authentication')[1]
  if title_index && authentication_index
    sections['introduction'] = lines[(title_index + 1)...authentication_index].join.strip
  end
  heading_indices.each_with_index do |(name, heading_index), position|
    next unless heading_index

    next_index = if position + 1 < heading_indices.length
                   heading_indices[position + 1][1]
                 else
                   first_model_index
                 end
    sections[name] = lines[(heading_index + 1)...next_index].join.strip if next_index
  end

  groups = {}
  lines.each_with_index do |line, index|
    match = line.match(/^# Group (.+)/)
    next unless match

    cursor = index + 1
    body = []
    while cursor < lines.length && !lines[cursor].match?(/^#+ /)
      body << lines[cursor]
      cursor += 1
    end
    groups[match[1].strip] = body.join.strip
  end

  models = []
  model_examples = {}
  invalid_model_examples = []
  lines.each_with_index do |line, index|
    match = line.match(/^## (\d+) \[\/\d+\]\s*$/)
    next unless match

    name = "#{match[1]}Model"
    models << name
    cursor = index + 1
    body = []
    while cursor < lines.length && !lines[cursor].match?(/^## /)
      body << lines[cursor]
      cursor += 1
    end
    json = body.join[/\{.*\}/m]
    begin
      model_examples[name] = JSON.parse(json) if json
    rescue JSON::ParserError
      invalid_model_examples << name
    end
  end

  host = lines.find { |line| line.start_with?('HOST:') }.to_s.sub(/^HOST:\s*/, '').strip
  {
    overview: overview,
    sections: sections,
    groups: groups,
    models: models.uniq,
    model_examples: model_examples,
    invalid_model_examples: invalid_model_examples,
    host: host
  }
end

def nested_strings(value)
  case value
  when Hash
    value.values.flat_map { |child| nested_strings(child) }
  when Array
    value.flat_map { |child| nested_strings(child) }
  when String
    [value]
  else
    []
  end
end

def resolve_schema(schema, document)
  return {} unless schema.is_a?(Hash)
  return schema unless schema['$ref']

  schema['$ref'].sub(%r{\A#/}, '').split('/').reduce(document) { |value, key| value.fetch(key, {}) }
end

def schema_paths(schema, document, prefix = nil, seen = [])
  schema = resolve_schema(schema, document)
  return [] unless schema.is_a?(Hash)
  return [] if seen.include?(schema.object_id)

  seen = seen + [schema.object_id]
  if schema['type'] == 'array'
    array_prefix = prefix || '[]'
    return schema_paths(schema['items'], document, array_prefix, seen)
  end

  properties = schema['properties'] || {}
  properties.flat_map do |name, child|
    path = [prefix, name].compact.join('.')
    [path] + schema_paths(child, document, path, seen)
  end.uniq
end

def schema_descriptions(schema, document, prefix = nil, seen = [])
  schema = resolve_schema(schema, document)
  return {} unless schema.is_a?(Hash)
  return {} if seen.include?(schema.object_id)

  seen = seen + [schema.object_id]
  if schema['type'] == 'array'
    array_prefix = prefix || '[]'
    return schema_descriptions(schema['items'], document, array_prefix, seen)
  end

  schema.fetch('properties', {}).each_with_object({}) do |(name, child), descriptions|
    path = [prefix, name].compact.join('.')
    resolved_child = resolve_schema(child, document)
    description = child['description'] || resolved_child['description']
    descriptions[path] = description.to_s.strip unless description.to_s.strip.empty?
    descriptions.merge!(schema_descriptions(child, document, path, seen))
  end
end

def schema_metadata(schema, document, prefix = nil, seen = [])
  schema = resolve_schema(schema, document)
  return {} unless schema.is_a?(Hash)
  return {} if seen.include?(schema.object_id)

  seen = seen + [schema.object_id]
  if schema['type'] == 'array'
    array_prefix = prefix || '[]'
    return schema_metadata(schema['items'], document, array_prefix, seen)
  end

  required_fields = schema.fetch('required', [])
  schema.fetch('properties', {}).each_with_object({}) do |(name, child), metadata|
    path = [prefix, name].compact.join('.')
    resolved_child = resolve_schema(child, document)
    metadata[path] = {
      type: resolved_child['type'],
      required: required_fields.include?(name),
      example: child['example'] || resolved_child['example']
    }
    metadata.merge!(schema_metadata(child, document, path, seen))
  end
end

def media_example(media_type, document)
  return nil unless media_type.is_a?(Hash)
  return media_type['example'] if media_type.key?('example')

  examples = media_type['examples']
  if examples.is_a?(Hash)
    examples.each_value do |example|
      return example['value'] if example.is_a?(Hash) && example.key?('value')
    end
  end

  schema = resolve_schema(media_type['schema'], document)
  schema['example'] if schema.is_a?(Hash)
end

def schema_component_refs(schema)
  return [] unless schema.is_a?(Hash)

  references = []
  references << schema['$ref'].split('/').last if schema['$ref']
  schema.fetch('oneOf', []).each do |candidate|
    references << candidate['$ref'].split('/').last if candidate.is_a?(Hash) && candidate['$ref']
  end
  references
end

def media_component_refs(media_type)
  return [] unless media_type.is_a?(Hash)

  references = schema_component_refs(media_type['schema'])
  media_type.fetch('x-apiary-response-models', []).each do |candidate|
    references << candidate['$ref'].split('/').last if candidate.is_a?(Hash) && candidate['$ref']
  end
  references.uniq
end

def openapi_operations(document)
  document.fetch('paths', {}).flat_map do |path, path_item|
    path_item.map do |method, operation|
      next unless HTTP_METHODS.include?(method)

      parameters = operation.fetch('parameters', [])
      request_body = operation['requestBody'] || {}
      if request_body['$ref']
        request_body = resolve_schema(request_body, document)
      end
      request_schema = request_body.dig('content', 'application/json', 'schema')
      request_example = media_example(request_body.dig('content', 'application/json'), document)
      responses = operation.fetch('responses', {}).transform_values do |response|
        schema = response.dig('content', 'application/json', 'schema')
        schema_paths(schema, document)
      end
      response_descriptions = operation.fetch('responses', {}).transform_values do |response|
        schema = response.dig('content', 'application/json', 'schema')
        schema_descriptions(schema, document)
      end
      response_metadata = operation.fetch('responses', {}).transform_values do |response|
        schema = response.dig('content', 'application/json', 'schema')
        schema_metadata(schema, document)
      end
      response_examples = operation.fetch('responses', {}).transform_values do |response|
        media_example(response.dig('content', 'application/json'), document)
      end
      response_refs = operation.fetch('responses', {}).transform_values do |response|
        media_component_refs(response.dig('content', 'application/json'))
      end
      {
        method: method,
        path: path,
        summary: operation['summary'],
        description: operation['description'].to_s.strip,
        parameters: parameters.reject { |parameter| parameter['in'] == 'header' }.map { |parameter| parameter['name'] },
        parameter_descriptions: parameters.reject { |parameter| parameter['in'] == 'header' }.to_h do |parameter|
          [parameter['name'], parameter['description'].to_s.strip]
        end,
        parameter_metadata: parameters.reject { |parameter| parameter['in'] == 'header' }.to_h do |parameter|
          [parameter['name'], {
            type: parameter.dig('schema', 'type'),
            required: parameter['required'],
            example: parameter['example']
          }]
        end,
        headers: parameters.select { |parameter| parameter['in'] == 'header' }.to_h do |parameter|
          [parameter['name'], { example: parameter['example'], default: parameter.dig('schema', 'default') }]
        end,
        request_paths: schema_paths(request_schema, document),
        request_descriptions: schema_descriptions(request_schema, document),
        request_metadata: schema_metadata(request_schema, document),
        request_example: request_example,
        response_statuses: responses.keys,
        response_examples: response_examples,
        response_refs: response_refs,
        response_descriptions: response_descriptions,
        response_metadata: response_metadata,
        response_paths: responses,
        raw: operation
      }
    end.compact
  end
end

def canonical_path(path)
  normalize_path(path).sub(/\?.*\z/, '')
end

sync_examples = ARGV.delete('--sync-examples')
usage! unless ARGV.length == 2

apib_operations = parse_apib(ARGV[0])
openapi = YAML.safe_load(File.read(ARGV[1]), [Date, Time], [], true)
oas_operations = openapi_operations(openapi)

matched = []
missing_operations = []
apib_operations.each do |source|
  target = oas_operations.find { |operation| operation[:method] == source[:method] && operation[:path] == source[:path] }
  target ||= oas_operations.find do |operation|
    operation[:method] == source[:method] && canonical_path(operation[:path]) == canonical_path(source[:path])
  end
  target ? matched << [source, target] : missing_operations << source
end

extra_operations = oas_operations.reject do |target|
  matched.any? { |_source, candidate| candidate.equal?(target) }
end

if sync_examples
  changed_examples = 0
  added_content_type_headers = 0
  removed_get_content_type_headers = 0
  synchronized_response_models = 0

  matched.each do |source, target|
    operation = target[:raw]
    if source[:request_example]
      request_body = operation['requestBody'] ||= {}
      content = request_body['content'] ||= {}
      media_type = content['application/json'] ||= {}
      existing = media_example(media_type, openapi)
      changed_examples += 1 if existing != source[:request_example] || media_type.key?('examples')
      media_type.delete('examples')
      media_type['example'] = source[:request_example]
    end

    parameters = operation['parameters'] ||= []
    if source[:method] == 'get'
      original_length = parameters.length
      parameters.reject! { |parameter| parameter['in'] == 'header' && parameter['name'] == 'Content-Type' }
      removed_get_content_type_headers += original_length - parameters.length
    elsif source[:request_media_type] == 'application/json'
      unless parameters.any? { |parameter| parameter['in'] == 'header' && parameter['name'] == 'Content-Type' }
        parameters << {
          'name' => 'Content-Type',
          'in' => 'header',
          'description' => 'Media type of the JSON request body.',
          'required' => false,
          'example' => 'application/json',
          'schema' => { 'type' => 'string', 'default' => 'application/json' }
        }
        added_content_type_headers += 1
      end
    end

    source[:response_examples].each do |status, example|
      response = operation.fetch('responses').fetch(status)
      content = response['content'] ||= {}
      media_type = content['application/json'] ||= {}
      existing = media_example(media_type, openapi)
      changed_examples += 1 if existing != example || media_type.key?('examples')
      media_type.delete('examples')
      media_type['example'] = example
    end


    source[:response_refs].each do |status, codes|
      component_names = codes.uniq.map { |code| "#{code}Model" }.select do |name|
        openapi.dig('components', 'schemas', name)
      end
      next if component_names.empty?

      response = operation.fetch('responses')[status] ||= {
        'description' => status == '400' ? 'Bad Request' : 'Response'
      }
      content = response['content'] ||= {}
      media_type = content['application/json'] ||= {}
      current_refs = media_component_refs(media_type)
      synchronized_response_models += 1 if (component_names - current_refs).any? || (current_refs - component_names).any?
      media_type['schema'] = { '$ref' => "#/components/schemas/#{component_names.first}" }
      if component_names.length > 1
        media_type['x-apiary-response-models'] = component_names.map { |name| { '$ref' => "#/components/schemas/#{name}" } }
      else
        media_type.delete('x-apiary-response-models')
      end

      variants = {}
      primary_example = deep_copy(media_type['example']) if media_type.key?('example')
      component_names.each do |name|
        component_example = openapi.dig('components', 'schemas', name, 'example')
        code = name.sub(/Model\z/, '')
        if component_example
          copied_example = deep_copy(component_example)
          variants["error_#{code}"] = { 'value' => copied_example }
          primary_example ||= deep_copy(copied_example)
        end
      end
      media_type.delete('example')
      media_type.delete('examples')
      media_type['examples'] = { 'response' => { 'value' => primary_example } } if primary_example
      if variants.length > 1
        media_type['x-apiary-response-examples'] = variants
      else
        media_type.delete('x-apiary-response-examples')
      end
    end
  end

  serialized = YAML.dump(openapi).sub(/\A---\s*\n/, '')
  File.write(ARGV[1], serialized)
  puts "Synchronized examples: #{changed_examples}"
  puts "Added Content-Type headers: #{added_content_type_headers}"
  puts "Removed GET Content-Type headers: #{removed_get_content_type_headers}"
  puts "Synchronized response model groups: #{synchronized_response_models}"
  exit
end

apib_document = parse_apib_document(ARGV[0])
overview_mismatch = normalized_content(apib_document[:overview]) != normalized_content(openapi.dig('info', 'description'))
server_mismatch = openapi.fetch('servers', []).none? { |server| server['url'] == apib_document[:host] }
target_tags = openapi.fetch('tags', []).to_h { |tag| [tag['name'], tag['description'].to_s] }
group_description_mismatches = apib_document[:groups].keys.select do |name|
  normalized_content(apib_document[:groups][name]) != normalized_content(target_tags[name])
end
target_schemas = openapi.fetch('components', {}).fetch('schemas', {})
missing_error_models = apib_document[:models] - target_schemas.keys
different_error_model_examples = apib_document[:model_examples].keys.select do |name|
  target_schemas.dig(name, 'example') != apib_document[:model_examples][name]
end

repository_root = File.expand_path('..', File.dirname(File.expand_path(ARGV[1])))
static_pages = STATIC_PAGE_TITLES.each_with_object({}) do |(name, title), pages|
  pages[name] = { path: File.join(repository_root, 'api', "#{name}.mdx"), title: title }
end
missing_static_pages = static_pages.values.map { |page| page[:path] }.reject { |path| File.file?(path) }
static_page_content_mismatches = static_pages.keys.select do |name|
  path = static_pages[name][:path]
  File.file?(path) && normalized_visible_content(apib_document[:sections][name]) != normalized_visible_content(mdx_body(path))
end

changelog_source = apib_document[:groups].fetch('Change Logs', '')
changelog_page = File.join(repository_root, 'api', 'changelog.mdx')
changelog_page_missing = !File.file?(changelog_page)
changelog_content_mismatch = false
unless changelog_page_missing
  changelog_content_mismatch = normalized_content(changelog_source) != normalized_content(mdx_body(changelog_page))
end
docs_config = File.join(repository_root, 'docs.json')
navigation_entries = File.file?(docs_config) ? nested_strings(JSON.parse(File.read(docs_config))) : []
changelog_navigation_missing = !navigation_entries.include?('api/changelog')
changelog_entries = changelog_source.lines.count { |line| line.start_with?('* <b>') }

group_pages = GROUP_PAGE_PATHS.each_with_object({}) do |(name, relative_path), pages|
  pages[name] = File.join(repository_root, "#{relative_path}.mdx")
end
missing_group_pages = group_pages.keys.select { |name| !File.file?(group_pages[name]) }
group_page_content_mismatches = group_pages.keys.select do |name|
  path = group_pages[name]
  File.file?(path) && normalized_visible_content(apib_document[:groups][name]) != normalized_visible_content(mdx_body(path))
end
group_navigation_missing = GROUP_PAGE_PATHS.keys.select do |name|
  !navigation_entries.include?(GROUP_PAGE_PATHS[name])
end

expected_page_titles = static_pages.values.each_with_object({}) do |page, titles|
  titles[page[:path]] = page[:title]
end
group_pages.each { |name, path| expected_page_titles[path] = name }
expected_page_titles[changelog_page] = 'Change Logs'
page_title_mismatches = expected_page_titles.keys.select do |path|
  File.file?(path) && mdx_title(path) != expected_page_titles[path]
end
unexpected_page_descriptions = expected_page_titles.keys.select do |path|
  File.file?(path) && mdx_frontmatter(File.read(path)).match?(/^description:/)
end

empty_descriptions = matched.select { |source, target| !source[:description].empty? && target[:description].empty? }
summary_mismatches = matched.select { |source, target| source[:summary] != target[:summary] }
description_mismatches = matched.select do |source, target|
  !source[:description].empty? && !target[:description].empty? && source[:description] != target[:description]
end

missing_parameters = []
different_parameter_descriptions = []
different_parameter_metadata = []
missing_headers = []
different_header_examples = []
missing_header_defaults = []
get_content_type_headers = []
missing_request_fields = []
different_request_field_descriptions = []
different_request_field_metadata = []
missing_request_examples = []
different_request_examples = []
missing_response_statuses = []
missing_response_models = []
missing_response_fields = []
different_response_field_descriptions = []
different_response_field_metadata = []
missing_response_examples = []
different_response_examples = []

matched.each do |source, target|
  parameter_gap = source[:parameters] - target[:parameters]
  missing_parameters << [source, parameter_gap] unless parameter_gap.empty?

  source[:parameter_descriptions].each do |name, description|
    target_description = target[:parameter_descriptions][name].to_s
    if normalized_field_description(target_description) != normalized_field_description(description)
      different_parameter_descriptions << [source, name, description, target_description]
    end
  end


  source[:parameter_metadata].each do |name, metadata|
    target_metadata = target[:parameter_metadata][name] || {}
    differences = []
    differences << "type #{target_metadata[:type].inspect} (expected #{metadata[:type].inspect})" if metadata[:type] && target_metadata[:type] != metadata[:type]
    if !metadata[:required].nil? && target_metadata[:required] != metadata[:required]
      differences << "required #{target_metadata[:required].inspect} (expected #{metadata[:required].inspect})"
    end
    if metadata[:example] && target_metadata[:example].to_s != metadata[:example]
      differences << "example #{target_metadata[:example].inspect} (expected #{metadata[:example].inspect})"
    end
    different_parameter_metadata << [source, name, differences] unless differences.empty?
  end

  header_gap = source[:headers].map(&:first) - target[:headers].keys
  missing_headers << [source, header_gap] unless header_gap.empty?

  source[:headers].each do |name, example|
    next unless target[:headers].key?(name)
    next if target[:headers][name][:example].to_s == example

    different_header_examples << [source, name, example, target[:headers][name][:example]]
  end

  default_gap = target[:headers].each_with_object([]) do |(name, values), fields|
    next unless %w[Accept Content-Type].include?(name)
    next if values[:default] && values[:default] == values[:example]

    fields << name
  end
  missing_header_defaults << [source, default_gap] unless default_gap.empty?

  if source[:method] == 'get' && target[:headers].key?('Content-Type')
    get_content_type_headers << source
  end

  request_gap = source[:request_paths] - target[:request_paths]
  missing_request_fields << [source, request_gap] unless request_gap.empty?

  source[:request_descriptions].each do |path, description|
    target_description = target[:request_descriptions][path].to_s
    if normalized_field_description(target_description) != normalized_field_description(description)
      different_request_field_descriptions << [source, path, description, target_description]
    end
  end


  source[:request_metadata].each do |path, metadata|
    target_metadata = target[:request_metadata][path] || {}
    differences = []
    differences << "type #{target_metadata[:type].inspect} (expected #{metadata[:type].inspect})" if metadata[:type] && target_metadata[:type] != metadata[:type]
    if !metadata[:required].nil? && target_metadata[:required] != metadata[:required]
      differences << "required #{target_metadata[:required].inspect} (expected #{metadata[:required].inspect})"
    end
    different_request_field_metadata << [source, path, differences] unless differences.empty?
  end

  if source[:request_example]
    if target[:request_example].nil?
      missing_request_examples << source
    elsif source[:request_example] != target[:request_example]
      different_request_examples << source
    end
  end

  response_status_gap = source[:response_statuses].uniq - target[:response_statuses]
  missing_response_statuses << [source, response_status_gap] unless response_status_gap.empty?

  source[:response_refs].each do |status, codes|
    expected_models = codes.uniq.map { |code| "#{code}Model" }
    model_gap = expected_models - target[:response_refs].fetch(status, [])
    missing_response_models << [source, status, model_gap] unless model_gap.empty?
  end

  source[:response_paths].each do |status, paths|
    response_gap = paths - target[:response_paths].fetch(status, [])
    missing_response_fields << [source, status, response_gap] unless response_gap.empty?
  end

  source[:response_descriptions].each do |status, descriptions|
    descriptions.each do |path, description|
      target_description = target[:response_descriptions].fetch(status, {})[path].to_s
      if normalized_field_description(target_description) != normalized_field_description(description)
        different_response_field_descriptions << [source, status, path, description, target_description]
      end
    end
  end


  source[:response_metadata].each do |status, fields|
    fields.each do |path, metadata|
      target_metadata = target[:response_metadata].fetch(status, {})[path] || {}
      differences = []
      differences << "type #{target_metadata[:type].inspect} (expected #{metadata[:type].inspect})" if metadata[:type] && target_metadata[:type] != metadata[:type]
      if !metadata[:required].nil? && target_metadata[:required] != metadata[:required]
        differences << "required #{target_metadata[:required].inspect} (expected #{metadata[:required].inspect})"
      end
      different_response_field_metadata << [source, status, path, differences] unless differences.empty?
    end
  end

  source[:response_examples].each do |status, example|
    if target[:response_examples][status].nil?
      missing_response_examples << [source, status]
    elsif example != target[:response_examples][status]
      different_response_examples << [source, status]
    end
  end
end

puts "APIB operations: #{apib_operations.length}"
puts "OpenAPI operations: #{oas_operations.length}"
puts "APIB group sections: #{apib_document[:groups].length}"
puts "APIB changelog entries: #{changelog_entries}"
puts "Different API overview: #{overview_mismatch ? 1 : 0}"
puts "Different server URL: #{server_mismatch ? 1 : 0}"
puts "Group descriptions that differ: #{group_description_mismatches.length}"
puts "Missing APIB error models: #{missing_error_models.length}"
puts "APIB error model examples compared exactly: #{apib_document[:model_examples].length}"
puts "APIB error models with invalid source JSON: #{apib_document[:invalid_model_examples].length}"
puts "APIB error model examples that differ: #{different_error_model_examples.length}"
puts "Missing standalone API pages: #{missing_static_pages.length}"
puts "Standalone API pages with different content: #{static_page_content_mismatches.length}"
puts "Missing API group overview pages: #{missing_group_pages.length}"
puts "API group overview pages with different content: #{group_page_content_mismatches.length}"
puts "Missing API group overview navigation: #{group_navigation_missing.length}"
puts "Source-derived pages with different titles: #{page_title_mismatches.length}"
puts "Source-derived pages with extra descriptions: #{unexpected_page_descriptions.length}"
puts "Missing changelog page: #{changelog_page_missing ? 1 : 0}"
puts "Different changelog page content: #{changelog_content_mismatch ? 1 : 0}"
puts "Missing changelog navigation: #{changelog_navigation_missing ? 1 : 0}"
puts "Matched operations: #{matched.length}"
puts "Missing operations: #{missing_operations.length}"
puts "Extra operations: #{extra_operations.length}"
puts "Different summaries: #{summary_mismatches.length}"
puts "Missing descriptions: #{empty_descriptions.length}"
puts "Different descriptions: #{description_mismatches.length}"
puts "Operations missing parameters: #{missing_parameters.length}"
puts "Parameter descriptions that differ: #{different_parameter_descriptions.length}"
puts "Parameters with different type/required/example metadata: #{different_parameter_metadata.length}"
puts "Operations missing headers: #{missing_headers.length}"
puts "Header examples that differ: #{different_header_examples.length}"
puts "Operations missing editable header defaults: #{missing_header_defaults.length}"
puts "GET operations with Content-Type headers: #{get_content_type_headers.length}"
puts "Operations missing request fields: #{missing_request_fields.length}"
puts "Request field descriptions that differ: #{different_request_field_descriptions.length}"
puts "Request fields with different type/required metadata: #{different_request_field_metadata.length}"
puts "Operations missing request examples: #{missing_request_examples.length}"
puts "Operations with different request examples: #{different_request_examples.length}"
puts "Operations missing response statuses: #{missing_response_statuses.length}"
puts "Responses missing referenced APIB models: #{missing_response_models.length}"
puts "Responses missing documented fields: #{missing_response_fields.length}"
puts "Response field descriptions that differ: #{different_response_field_descriptions.length}"
puts "Response fields with different type/required metadata: #{different_response_field_metadata.length}"
puts "Responses missing examples: #{missing_response_examples.length}"
puts "Responses with different examples: #{different_response_examples.length}"

if overview_mismatch
  puts "\nDIFFERENT API OVERVIEW"
  puts '- OpenAPI info.description does not match the APIB overview.'
end

if server_mismatch
  puts "\nDIFFERENT SERVER URL"
  puts "- Expected #{apib_document[:host]}"
end

unless group_description_mismatches.empty?
  puts "\nDIFFERENT GROUP DESCRIPTIONS"
  group_description_mismatches.each { |name| puts "- #{name}" }
end

unless missing_error_models.empty?
  puts "\nMISSING APIB ERROR MODELS"
  missing_error_models.each { |name| puts "- #{name}" }
end

unless apib_document[:invalid_model_examples].empty?
  puts "\nINVALID JSON IN APIB ERROR MODELS (INFORMATIONAL)"
  apib_document[:invalid_model_examples].each { |name| puts "- #{name}" }
end

unless different_error_model_examples.empty?
  puts "\nDIFFERENT APIB ERROR MODEL EXAMPLES"
  different_error_model_examples.each { |name| puts "- #{name}" }
end

unless missing_static_pages.empty?
  puts "\nMISSING STANDALONE API PAGES"
  missing_static_pages.each { |path| puts "- #{path}" }
end

unless static_page_content_mismatches.empty?
  puts "\nDIFFERENT STANDALONE API PAGE CONTENT"
  static_page_content_mismatches.each { |name| puts "- #{static_pages[name][:path]}" }
end

unless missing_group_pages.empty?
  puts "\nMISSING API GROUP OVERVIEW PAGES"
  missing_group_pages.each { |name| puts "- #{name}: #{group_pages[name]}" }
end

unless group_page_content_mismatches.empty?
  puts "\nDIFFERENT API GROUP OVERVIEW PAGE CONTENT"
  group_page_content_mismatches.each { |name| puts "- #{name}: #{group_pages[name]}" }
end

unless group_navigation_missing.empty?
  puts "\nMISSING API GROUP OVERVIEW NAVIGATION"
  group_navigation_missing.each { |name| puts "- #{name}: #{GROUP_PAGE_PATHS[name]}" }
end

unless page_title_mismatches.empty?
  puts "\nDIFFERENT SOURCE-DERIVED PAGE TITLES"
  page_title_mismatches.each do |path|
    puts "- #{path}: #{mdx_title(path).inspect} (expected #{expected_page_titles[path].inspect})"
  end
end

unless unexpected_page_descriptions.empty?
  puts "\nEXTRA SOURCE-DERIVED PAGE DESCRIPTIONS"
  unexpected_page_descriptions.each { |path| puts "- #{path}" }
end

puts "\nMISSING CHANGELOG PAGE\n- #{changelog_page}" if changelog_page_missing
puts "\nDIFFERENT CHANGELOG PAGE CONTENT\n- #{changelog_page}" if changelog_content_mismatch
puts "\nMISSING CHANGELOG NAVIGATION\n- api/changelog" if changelog_navigation_missing

unless missing_operations.empty?
  puts "\nMISSING OPERATIONS"
  missing_operations.each { |operation| puts "- #{operation[:method].upcase} #{operation[:source_path]} (APIB line #{operation[:source_line]})" }
end

unless extra_operations.empty?
  puts "\nEXTRA OPENAPI OPERATIONS"
  extra_operations.each { |operation| puts "- #{operation[:method].upcase} #{operation[:path]}" }
end

unless empty_descriptions.empty?
  puts "\nMISSING DESCRIPTIONS"
  empty_descriptions.each { |source, _target| puts "- #{source[:method].upcase} #{source[:path]} (APIB line #{source[:source_line]})" }
end

unless summary_mismatches.empty?
  puts "\nDIFFERENT SUMMARIES"
  summary_mismatches.each do |source, target|
    puts "- #{source[:method].upcase} #{source[:path]}: APIB=#{source[:summary].inspect}, OpenAPI=#{target[:summary].inspect}"
  end
end

unless description_mismatches.empty?
  puts "\nDIFFERENT DESCRIPTIONS"
  description_mismatches.each do |source, target|
    puts "- #{source[:method].upcase} #{source[:path]} (APIB line #{source[:source_line]})"
    puts "  APIB: #{source[:description].inspect}" if ENV['VERBOSE']
    puts "  OpenAPI: #{target[:description].inspect}" if ENV['VERBOSE']
  end
end

unless missing_parameters.empty?
  puts "\nMISSING PARAMETERS"
  missing_parameters.each { |source, fields| puts "- #{source[:method].upcase} #{source[:path]}: #{fields.join(', ')}" }
end

unless different_parameter_descriptions.empty?
  puts "\nDIFFERENT PARAMETER DESCRIPTIONS"
  different_parameter_descriptions.each do |source, name, expected, actual|
    puts "- #{source[:method].upcase} #{source[:path]} #{name}"
    puts "  APIB: #{expected.inspect}" if ENV['VERBOSE']
    puts "  OpenAPI: #{actual.inspect}" if ENV['VERBOSE']
  end
end

unless different_parameter_metadata.empty?
  puts "\nDIFFERENT PARAMETER METADATA"
  different_parameter_metadata.each do |source, name, differences|
    puts "- #{source[:method].upcase} #{source[:path]} #{name}: #{differences.join('; ')}"
  end
end

unless missing_headers.empty?
  puts "\nMISSING HEADERS"
  missing_headers.each { |source, fields| puts "- #{source[:method].upcase} #{source[:path]}: #{fields.join(', ')}" }
end

unless different_header_examples.empty?
  puts "\nDIFFERENT HEADER EXAMPLES"
  different_header_examples.each do |source, name, expected, actual|
    puts "- #{source[:method].upcase} #{source[:path]} #{name}: APIB=#{expected.inspect}, OpenAPI=#{actual.inspect}"
  end
end

unless missing_header_defaults.empty?
  puts "\nMISSING EDITABLE HEADER DEFAULTS"
  missing_header_defaults.each { |source, fields| puts "- #{source[:method].upcase} #{source[:path]}: #{fields.join(', ')}" }
end

unless get_content_type_headers.empty?
  puts "\nGET OPERATIONS WITH CONTENT-TYPE"
  get_content_type_headers.each { |source| puts "- GET #{source[:path]}" }
end

unless missing_request_fields.empty?
  puts "\nMISSING REQUEST FIELDS"
  missing_request_fields.each { |source, fields| puts "- #{source[:method].upcase} #{source[:path]}: #{fields.join(', ')}" }
end

unless different_request_field_descriptions.empty?
  puts "\nDIFFERENT REQUEST FIELD DESCRIPTIONS"
  different_request_field_descriptions.each do |source, path, expected, actual|
    puts "- #{source[:method].upcase} #{source[:path]} #{path}"
    puts "  APIB: #{expected.inspect}" if ENV['VERBOSE']
    puts "  OpenAPI: #{actual.inspect}" if ENV['VERBOSE']
  end
end

unless different_request_field_metadata.empty?
  puts "\nDIFFERENT REQUEST FIELD METADATA"
  different_request_field_metadata.each do |source, path, differences|
    puts "- #{source[:method].upcase} #{source[:path]} #{path}: #{differences.join('; ')}"
  end
end

unless missing_request_examples.empty?
  puts "\nMISSING REQUEST EXAMPLES"
  missing_request_examples.each { |source| puts "- #{source[:method].upcase} #{source[:path]}" }
end

unless different_request_examples.empty?
  puts "\nDIFFERENT REQUEST EXAMPLES"
  different_request_examples.each { |source| puts "- #{source[:method].upcase} #{source[:path]}" }
end

unless missing_response_statuses.empty?
  puts "\nMISSING RESPONSE STATUSES"
  missing_response_statuses.each { |source, statuses| puts "- #{source[:method].upcase} #{source[:path]}: #{statuses.join(', ')}" }
end

unless missing_response_models.empty?
  puts "\nMISSING RESPONSE MODELS"
  missing_response_models.each do |source, status, models|
    puts "- #{source[:method].upcase} #{source[:path]} [#{status}]: #{models.join(', ')}"
  end
end

unless missing_response_fields.empty?
  puts "\nMISSING RESPONSE FIELDS"
  missing_response_fields.each do |source, status, fields|
    puts "- #{source[:method].upcase} #{source[:path]} [#{status}]: #{fields.join(', ')}"
  end
end

unless different_response_field_descriptions.empty?
  puts "\nDIFFERENT RESPONSE FIELD DESCRIPTIONS"
  different_response_field_descriptions.each do |source, status, path, expected, actual|
    puts "- #{source[:method].upcase} #{source[:path]} [#{status}] #{path}"
    puts "  APIB: #{expected.inspect}" if ENV['VERBOSE']
    puts "  OpenAPI: #{actual.inspect}" if ENV['VERBOSE']
  end
end

unless different_response_field_metadata.empty?
  puts "\nDIFFERENT RESPONSE FIELD METADATA"
  different_response_field_metadata.each do |source, status, path, differences|
    puts "- #{source[:method].upcase} #{source[:path]} [#{status}] #{path}: #{differences.join('; ')}"
  end
end

unless missing_response_examples.empty?
  puts "\nMISSING RESPONSE EXAMPLES"
  missing_response_examples.each { |source, status| puts "- #{source[:method].upcase} #{source[:path]} [#{status}]" }
end

unless different_response_examples.empty?
  puts "\nDIFFERENT RESPONSE EXAMPLES"
  different_response_examples.each { |source, status| puts "- #{source[:method].upcase} #{source[:path]} [#{status}]" }
end

exit 1 unless !overview_mismatch && !server_mismatch && group_description_mismatches.empty? &&
              missing_error_models.empty? && different_error_model_examples.empty? &&
              missing_static_pages.empty? && !changelog_page_missing &&
              static_page_content_mismatches.empty? && missing_group_pages.empty? &&
              group_page_content_mismatches.empty? && group_navigation_missing.empty? &&
              page_title_mismatches.empty? && unexpected_page_descriptions.empty? &&
              !changelog_content_mismatch && !changelog_navigation_missing &&
              missing_operations.empty? && extra_operations.empty? && summary_mismatches.empty? && empty_descriptions.empty? &&
              description_mismatches.empty? && missing_parameters.empty? && different_parameter_descriptions.empty? &&
              different_parameter_metadata.empty? &&
              missing_headers.empty? && different_header_examples.empty? && missing_header_defaults.empty? &&
              get_content_type_headers.empty? &&
              missing_request_fields.empty? && different_request_field_descriptions.empty? &&
              different_request_field_metadata.empty? &&
              missing_request_examples.empty? && different_request_examples.empty? &&
              missing_response_statuses.empty? && missing_response_models.empty? && missing_response_fields.empty? &&
              different_response_field_descriptions.empty? && different_response_field_metadata.empty? &&
              missing_response_examples.empty? &&
              different_response_examples.empty?
