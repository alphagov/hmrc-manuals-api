# HMRC Manuals API

This app provides URLs for pushing HMRC manuals into the content store.

## Creating a new manual

### Request

`POST /hmrc-manuals` with `Content-Type: application/vnd.govuk.hmrc-manual+json`.

### Success response

Status code: `201`.
`Location` header: `/hmrc-manuals/<slug>`

The API will generate the slug from the title of the manual.

### If the generated slug already exists on GOV.UK

* `302`: the slug is taken by an existing HMRC manual (possibly the one you're posting).

    The `Location` header points to the existing manual.

* `409`: the slug is taken by content that is managed by another publishing tool.

## Updating an existing manual

### Request

`PUT /hmrc-manuals/<manual-slug>` with `Content-Type: application/vnd.govuk.hmrc-manual+json`.

### Success response

Status code: `200`.

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
