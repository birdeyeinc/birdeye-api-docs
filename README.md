# Birdeye MCP Server — Documentation

The **Birdeye MCP Server** connects AI assistants like Claude and ChatGPT directly to your Birdeye account using the [Model Context Protocol (MCP)](https://modelcontextprotocol.io) — an open standard for secure, real-time access to external data. Point your AI client at `https://mcp.birdeye.com/mcp`, authorize with your Birdeye credentials, and start asking natural-language questions about your reviews, listings, surveys, social performance, and more. This repo contains the documentation site, built with [Mintlify](https://mintlify.com).

📖 **Live Docs:** _URL to be added once hosting is finalized_

**MCP Server URL:** `https://mcp.birdeye.com/mcp`

## Available Tools

| Category | Tools |
|---|---|
| Reviews | Get reviews, get review summary, review & rating overview |
| Business | Get business info, get child locations |
| Surveys | Get all surveys, get survey responses |
| Listings | Get listing, listing status report, listing insights, category list, product listing list |
| Search AI | Configuration, available runs, citations, businesses, accuracy report, sentiment report |
| Social | Track social post, get open URL performance report |
| Ticketing | Get all ticket data |
| Aggregation | Get all aggregation sources, get review site aliases |

## Quickstart

1. Add `https://mcp.birdeye.com/mcp` as a connector in your AI client (Claude or ChatGPT)
2. Authorize with your Birdeye credentials via OAuth 2.0
3. Start asking questions about your Birdeye data

Full setup instructions: [quickstart.mdx](./quickstart.mdx)

## Repo Structure

```
.
├── docs.json              # Mintlify navigation and theme config
├── introduction.mdx       # Landing page
├── quickstart.mdx         # Setup guide for Claude, ChatGPT, and other clients
├── authentication.mdx     # OAuth 2.0 flow details
├── images/                # Logos and assets
└── tools/                 # Tool reference docs
    ├── overview.mdx
    ├── reviews/
    ├── business/
    ├── surveys/
    ├── listings/
    ├── search-ai/
    ├── social/
    ├── ticketing/
    └── aggregation/
```

## Local Development

Install the [Mintlify CLI](https://www.npmjs.com/package/mintlify) and run a local preview:

```bash
npm install -g mintlify
mintlify dev
```

The docs will be available at `http://localhost:3000`.

## Contributing

1. Edit or add `.mdx` files in the relevant folder
2. Update `docs.json` if adding new pages to the navigation
3. Preview locally with `mintlify dev` before pushing

## Security

To report a security vulnerability, please **do not** open a public GitHub issue. Instead:

- Email [security@birdeye.com](mailto:security@birdeye.com)
- Visit [trust.birdeye.com](https://trust.birdeye.com) for our security policies and disclosure program

## Support & Contact

For questions about the MCP server or this documentation, reach out to:

- [rajeev.vikram@birdeye.com](mailto:rajeev.vikram@birdeye.com)
- [vinesh.kumar@birdeye.com](mailto:vinesh.kumar@birdeye.com)
- [vikram.kumar@birdeye.com](mailto:vikram.kumar@birdeye.com)

## Links

- [Birdeye Platform](https://birdeye.com)
- [MCP Server](https://mcp.birdeye.com/mcp)
- [Mintlify Docs](https://mintlify.com/docs)
