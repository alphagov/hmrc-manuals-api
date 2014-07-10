# HMRC Manuals API

This app provides URLs for pushing HMRC manuals into the content store.

## Adding or updating a manual

### Request

`PUT /hmrc-manuals/<slug>` with `Content-Type: application/vnd.govuk.hmrc-manual+json`.

### Possible responses

* `200`: updated successfully
* `201`: created successfully
* `409`: the slug is taken by content that is managed by another publishing tool.

## Adding or updating a manual section

### Request

`PUT /hmrc-manuals/<manual-slug>/sections/<section_id>` with `Content-Type: application/vnd.govuk.hmrc-manual-section+json`.

### Success response

* Status code: `201` if created.
* Status code: `200` if updated.

## Possible error responses

* `400`: the request JSON isn't well-formed.
* `422`: there's a validation error.

    ```json
    {
      "status": "error",
      "errors": [
        {
          "key": "error_message"
        },...
      ]
    }
    ```

* `503`: the request could not be completed because the API or the content store is unavailable.
