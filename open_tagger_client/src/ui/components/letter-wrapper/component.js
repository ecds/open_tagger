import Component from '@ember/component';
import { action } from '@ember-decorators/object';
import { camelize } from '@ember/string';

export default class LetterWrapperComponent extends Component {
  classNameBindings = ['showPerson:person', 'showPlace:place', 'showWriting:writing', 'showEvent:event', 'showTranslating:translating', 'showEventAttended:event-attended', 'showPublicEvent:public-event', 'showProduction:production', 'showReading:reading', 'showFlagged:flagged']

  showPerson = true
  showPlace = true
  showWriting = true
  showEvent = true
  showTranslating = true
  showEventAttended = true
  showPublicEvent = true
  showProduction = true
  showReading = true
  showFlagged = true

  types = [
    {
      label: 'Person',
      show: this.showPerson
    },
    {
      label: 'Place',
      show: this.showPlace
    },
    {
      label: 'Writing',
      show: this.showWriting
    },
    {
      label: 'Event',
      show: this.showEvent
    },
    {
      label: 'Translating',
      show: this.showTranslating
    },
    {
      label: 'Event Attended',
      show: this.showEventAttended
    },
    {
      label: 'Public Event',
      show: this.showPublicEvent
    },
    {
      label: 'Production',
      show: this.showProduction
    },
    {
      label: 'Reading',
      show: this.showReading
    }
  ]

  @action
  toggleTag(entityType) {
    if (typeof entityType === 'string') {
      this.set(camelize(`show${entityType}`), this.camelize(`show${entityType}`));
    } else {
      this.set(camelize(`show${entityType.label}`), entityType.show);
    }
  }
}
