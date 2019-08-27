# OpenTagger API Server

## Endpoints

|  |  |
| ------------ | --------------- |
| Entity Types | `/entity-types` |
| Entities by Type | `/entities?type=<entity_type>` |
| Specific Entity | `/entities/<id>` |
| Search Entity | `/search-entities?query=<search_terms>&type=<entity_type>` |

### Letters

|||
| ------------ | --------------- |
| Letters | `/letters?` |

#### Letter Parameters

Any or all of the following parameters maybe be added to the request. If a parameter is not included in the request, the default will be applied.

| Parameter | Value | Default |
| - | - | - |
| start | Date | Date of earliest letter |
| end | Date | Date of last letter |
| recipients | Person labels separated by a comma | All |
| repository | Repository Label | All |
| items | Number of records to fetch | 25 |
| page | Offset for paginated results | 1 |

##### Example

`/letters?start=<date>&end=<date>&recipients=<person_label>&repository=<repository_label&items=15&page=2>`

## Entity Schema

~~~json
{
  "people": {
    "legacy_id": "INT",
    "label": "",
    "properties": {
      "last_name": "",
      "first_name": "",
      "alternate_names_spellings": [
        ""
      ],
      "life_dates": "",
      "description": "",
      "links": [
        "link"
      ],
      "profile": "",
      "finding_aids": [
        "link"
      ],
      "media": {
        "images": [
          {
            "link": "",
            "caption": "",
            "attribution": ""
          }
        ],
        "videos": [
          {
            "link": "",
            "caption": "",
            "attribution": ""
          }
        ]
      }
    }
  },
  "organizations": {
    "legacy_id": "INT",
    "label": "",
    "properties": {
      "name": "",
      "alternate_spelling": [""],
      "description": "",
      "profile": ""
    }
  },
  "places": {
    "legacy_id": "INT",
    "label": "",
    "properties": {
      "links": [
        "geonames"
      ],
      "coordinates": {
        "lat": "FLOAT",
        "lng": "FLOAT"
      }
      "description": "",
      "alternate_spellings": [
        ""
      ]
    }
  },
  "reading": {
    "legacy_id": "INT",
    "label": "",
    "properties": {
      "authors": [
        "PERSON LABEL"
      ],
      "publication": ""
    }
  },
  "productions": {
    "legacy_id": "INT",
    "label": "",
    "properties": {
      "director": "PERSON LABEL",
      "city": "PLACE LABEL",
      "date": "DATE",
      "cast": [
        {
          "actor": "",
          "role": ""
        }
      ],
      "notes": "",
      "staging_beckett": ""
    }
  },
  "works_of_art": {
    "legacy_id": "INT",
    "label": "",
    "properties": {
      "artist": "PERSON LABEL",
      "alternate_spellings": "",
      "description": "",
      "owner": "PERSON LABEL",
      "location": "PLACE LABEL"
    }
  },
  "translating": {
    "legacy_id": "INT",
    "label": "",
    "properties": {
      "author": "PERSON LABEL",
      "translated_title": "",
      "translated_into": "LANGUAGE",
      "translators": [
        "PERSON"
      ]
    }
  },
  "writing": {
    "legacy_id": "INT",
    "label": "",
    "properties": {
      "date": "DATE",
      "proposal": "",
      "response": "?"
    }
  },
  "public_events": {
    "legacy_id": "INT",
    "label": "",
    "properties": {
      "title": "",
      "date": "DATE"
    }
  },
  "music": {
    "legacy_id": "INT",
    "label": "",
    "properties": {
      "alternative_titles": [
        ""
      ],
      "description": "",
      "notes": "",
      "performed_by": [
        "PERSON LABEL"
      ]
    }
  },
  "attendance": {
    "legacy_id": "INT",
    "label": "",
    "properties": {
      "attended": "?",
      "place": "PLACE LABEL",
      "date": "DATE",
      "attends_with": [
        "PERSON LABEL"
      ],
      "performed_by": "?"
    }
  },
  "publication": {
    "legacy_id": "INT",
    "label": "",
    "properties": {
      "author": "PERSON LABEL",
      "translator": "PERSON LABEL",
      "place": "PLACE LABEL",
      "publisher": "ORGANIZATION LABEL",
      "date": "DATE",
      "notes": ""
    }
  }
}
~~~
