import Component from '@ember/component';
import autoComplete from '@tarekraafat/autocomplete.js';
import fetch from 'fetch';

export default class AutoCompleteComponent extends Component {
  aC = null;
  firstFetch = true;

  select(event) {
    this.args.filterRecipients(event.selection.match);
  }

  constructor(args) {
    super(args);
    this.aC = new autoComplete({
      data: {
        src: async () => {

          if (args.recipientsList) {
            return args.recipientsList;
          }
          const source = await fetch('https://ot-api.ecdsdev.org/letter-recipients');
          const data = await source.json();
          args.enableAutoComplete(data);
          return data;
        },
        key: ['recipient']
      },
      onSelection: event => {
         args.filterRecipients(event.selection.match);
         document.querySelector("#autoComplete_results_list").classList.remove("uk-padding-small");
      },
      threshold: 2,
      resultsList: {
        render: true,
        container: source => {
          source.setAttribute("id", "autoComplete_results_list");
          source.setAttribute( "class", "uk-list auto-complete-list uk-list-divider");
        },
        destination: document.querySelector("#autoComplete"),
        position: "afterend",
        element: "ul"
      },
      resultItem: {
        content: (data, source) => {
          source.innerHTML = data.match;
          document.querySelector("#autoComplete_results_list").classList.add("uk-padding-small")
        },
        element: "li"
      },
      query: {
        manipulate: function (query) {
          if (query == '') {
            document.querySelector("#autoComplete_results_list").classList.remove("uk-padding-small");
          }
          return query;
        },
      },
      noResults: () => {
        document.querySelector("#autoComplete_results_list").classList.remove("uk-padding-small");
      }
    })
  }
}
