const search = instantsearch({
  indexName: "memex",
  searchClient: instantMeiliSearch("http://localhost:7700", "", {
    paginationTotalHits: 20, // default: 200.
    placeholderSearch: true, // default: true.
    attributesToHighlight: []
  }),
  routing: true,
  // attributesForFaceting: ['provider', 'verb'],
  stalledSearchDelay: 0
});

function renderItem(item, lastDate) {
  const content = item.provider === 'Safari' ?
    `
    <a href="${item.website_url}" target="_blank">
      ${instantsearch.highlight({attribute: 'website_title', hit: item})}
      <div class="text-xs text-gray-300 dark:text-gray-500 overflow-ellipsis whitespace-nowrap overflow-hidden">
        ${item.device_name}: ${instantsearch.highlight({attribute: 'website_url', hit: item})}  
      </div>
    </a>
    `
    :
    `
    <div class="text-xs text-gray-300 dark:text-gray-500 overflow-ellipsis whitespace-nowrap overflow-hidden">
        ${item.person_name}
    </div>
    ${instantsearch.highlight({attribute: 'message_text', hit: item})}
    `;

  const date = new Date(item.timestamp_unix * 1000);
  const dateLine = (!lastDate || date.toLocaleDateString() !== lastDate.toLocaleDateString()) ? `
    <div class="flex w-auto items-start">
      <figure class="flex-none self-center inline-block rounded-full w-2 h-2 -ml-1 dark:bg-gray-300"></figure>
      <div class="text-base font-medium text-gray-900 p-3 dark:text-gray-500">${date.toDateString()}</div>
    </div>
  ` : ``;

  const dot = item.provider === 'Safari' ?
    `<img class="flex-none self-center inline-block w-6 h-6 -ml-3" src="./assets/images/safari-small.png" />`
    : item.provider === 'iMessage' ?
    `<img class="flex-none self-center inline-block w-6 h-6 -ml-3" src="./assets/images/iMessage-small.png" />`
    :
    `<figure class="flex-none self-center inline-block rounded-full w-2 h-2 -ml-1 dark:bg-gray-300"></figure>`;

  return `
    <div class="border-l border-gray-500 ml-32">
      ${dateLine}
      <div class="flex w-auto items-start">
        <div class="flex-none self-center text-right text-gray-900 dark:text-gray-500 -ml-32 w-32 pr-5">${date.toLocaleTimeString('nl-NL')}</div>
        ${dot}
        <div class="flex-grow rounded-md bg-gray-200 dark:bg-gray-900 p-4 my-2 ml-4 shadow-md overflow-hidden dark:text-white">
            ${content}
        </div>
      </div>
    </div> 
  `;
}

const renderInfiniteHits = (renderOptions, isFirstRender) => {
  const {hits, showMore, widgetParams} = renderOptions;
  const container = document.querySelector(widgetParams.container);
  let lastRenderOptions = renderOptions;

  if (isFirstRender) {
    const sentinel = document.createElement('span');
    container.appendChild(document.createElement('div'));
    container.appendChild(sentinel);

    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !lastRenderOptions.isLastPage) {
          showMore();
        }
      });
    });

    observer.observe(sentinel);

    return;
  }

  // ✅ Date separators
  // Todo: Infinite scroll
  // Todo: Date facet
  // Todo: Start/end blocks?
  // Todo: Nice design ;-)
  // Todo: Autocomplete with facets
  let lastDate = null;
  container.querySelector('div').innerHTML = hits
    .map(item => {
      const html = renderItem(item, lastDate);
      lastDate =  new Date(item.timestamp_unix * 1000);

      return html;
    })
    .join('');
};

const customInfiniteHits = instantsearch.connectors.connectInfiniteHits(
  renderInfiniteHits
);

// const virtualRefinementList = instantsearch.connectors.connectRefinementList(
//   () => null
// );

search.addWidgets([
  instantsearch.widgets.searchBox({
    container: "#searchbox",
    autofocus: true,
    showSubmit: false,
    showReset: false,
    showLoadingIndicator: false,
    cssClasses: {
      input: [
        'focus:ring-blue-900', 'focus:ring-2', 'w-full', 'text-black', 'dark:text-white',
        'dark:bg-black', 'px-10', 'py-4', 'rounded-xl'
      ],
    },
  }),
  customInfiniteHits({
    container: '#hits',
  }),
  instantsearch.widgets.refinementList({
    container: '#date-facet',
    attribute: 'date_month',
    sortBy: ['name:desc'],
    limit: 9999,
    transformItems(items) {
      const total = items.reduce((total, item) => total < item.count ? item.count : total, 0);
      const percentile = (100 / total) * 0.01;

      return items.map(item => ({
        ...item,
        percentage: total === 0 ? 0 : percentile * item.count,
      }));
    },
    templates: {
      item: ({url, label, percentage, count}) => `
        <a
            href="${url}"
            title="${label} (${count})"
            class="bg-gray-700 ml-auto block mb-px h-2"
            style="width: ${Math.max(1, percentage * 250)}px;" >
        </a>
      `
    }
  }),
  instantsearch.widgets.menu({
    container: '#provider-facet',
    attribute: 'provider',
    sortBy: ['name:asc'],
    cssClasses: {
      'root': 'inline-block',
      'item': 'inline-block'
    },
    templates: {
      item: `
        <a href="{{url}}" class="inline p-2 px-3 rounded-full {{#isRefined}} bg-gray-700{{/isRefined}}">
          <span class="">{{label}}</span>
          <span class="text-gray-500">({{#helpers.formatNumber}}{{count}}{{/helpers.formatNumber}})</span>
        </a>
    `,
    },
  }),
  instantsearch.widgets.menu({
    container: '#verb-facet',
    attribute: 'verb',
    sortBy: ['name:asc'],
    cssClasses: {
      'root': 'inline-block',
      'item': 'inline-block'
    },
    templates: {
      item: `
        <a href="{{url}}" class="inline p-2 px-3 rounded-full {{#isRefined}} bg-gray-700{{/isRefined}}">
          <span class="">{{label}}</span>
          <span class="text-gray-500">({{#helpers.formatNumber}}{{count}}{{/helpers.formatNumber}})</span>
        </a>
    `,
    },
  }),
]);

search.start();
