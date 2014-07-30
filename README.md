# HMRC Manuals API

This app provides URLs for pushing HMRC manuals into the content store.

## Adding or updating a manual

### Request

`PUT /hmrc-manuals/<slug>`.

### Example JSON

[See an example manual](json_examples/requests/employment-income-manual.json)


### JSON Schema

[JSON Schema for manuals](public/manual-schema.json)

## Adding or updating a manual section

### Request

`PUT /hmrc-manuals/<manual-slug>/sections/<section_id>`.

### Example JSON

1. [An example first-level section, with children](json_examples/requests/employment-income-manual/EIM11800.json)
1. [An example third-level section](json_examples/requests/employment-income-manual/EIM25525.json)
1. [An example section with ungrouped children](json_examples/requests/employment-income-manual/EIM11200.json) (the group title is omitted and only one group included)


### JSON Schema

[JSON Schema for sections](public/section-schema.json)

## Possible responses to PUT requests

* `200`: updated successfully
* `201`: created successfully
* `400`: the request JSON isn't well-formed.
* `409`: the slug is taken by content that is managed by another publishing tool.
* `422`: there's a validation error. A response body would detail the errors:

    ```json
    {
      "status": "error",
      "errors": [
        "error_message_1",
        "error_message_2",
        ...
      ]
    }
    ```

* `503`: the request could not be completed because the API or the content store is unavailable.
