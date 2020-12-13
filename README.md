# Building a Memex

Search of my personal data (including but not limited to notes, messages, financial transactions, 
photos, videos, visited places, traveled routes, browser history, CLI commands,
version control commits, ...). 

Similar to the quantified self movement where as much data as possible is collected. 
However, the idea is to build a tool to remind myself of things I did and learned from 
the past instead of focusing on the data visualization part. The notes database is a 
subset of this idea. 

Inspired by the [talk Building a Memex](https://www.youtube.com/watch?v=DFWxvQn4cf8&t=1616s) by Andrew Louis.
Andrew has written many interesting [blog posts](https://hyfen.net/memex/) while building a Memex.

### What is a Memex?

> Memex is [...] a device in which individuals would compress and store 
> all of their books, records, and communications, "mechanized so that 
> it may be consulted with exceeding speed and flexibility".

Source: [Wikipedia](https://en.wikipedia.org/wiki/Memex)

### Installation
```
# Setup environment (once)
brew bundle
cp .envrc.dist .envrc
direnv allow

# Start services
./bin-dev/start.sh

# Setup the index config (once)
./bin-dev/setup-index.sh

# Import some data
./bin-dev/import.sh sqlite-to-meilisearch/iMessage.sh

open http://localhost:4000
```

### Links
- Icons https://macosicons.com
