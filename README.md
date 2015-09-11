# HMRC Manuals API

This app provides URLs for pushing HMRC manuals to the GOV.UK Publishing API.

## Connecting to the API

The base path for the preview environment is:
https://hmrc-manuals-api.preview.alphagov.co.uk

Authentication is done with a token, which needs to be supplied in the `Authorization` HTTP header, like this:

    Authorization: Bearer your_token

You also need to supply an accept header and a Content-Type header:

    Accept: application/json
    Content-Type: application/json

Please note that:

* Tokens are environment specific, so preview and production will have different tokens.
* The data on preview is overwritten every night with data from production.

## Adding or updating a manual

### Request

    PUT /hmrc-manuals/<slug>

The `<slug>` is used as part of the GOV.UK URL for the document.

### Example JSON

[See an example manual](/public/json_examples/requests/employment-income-manual.json)


### JSON Schema

[JSON Schema for manuals](public/manual-schema.json)

## Adding or updating a manual section

### Request

    PUT /hmrc-manuals/<manual-slug>/sections/<section_slug>

The `<manual-slug>` and `<section_slug>` will be used as part of the GOV.UK URL for the document. The `<section_slug>` will be the section ID converted to lowercase.

### Example JSON

1. [An example first-level section, with children](/public/json_examples/requests/employment-income-manual/eim11800.json)
1. [An example third-level section](/public/json_examples/requests/employment-income-manual/eim25525.json)
1. [An example section with ungrouped children](/public/json_examples/requests/employment-income-manual/eim11200.json) (the group title is omitted and only one group included)


### JSON Schema

[JSON Schema for sections](public/section-schema.json)

## Possible responses to PUT requests

* `200`: updated successfully
* `201`: created successfully
  * Both `200`s and `201`s return a `Location` header and a response body containing the GOV.UK URL of the manual:

        Location: https://www.gov.uk/hmrc-internal-manuals/<manual_slug>/<section_slug>

        {
          "govuk_url": "https://www.gov.uk/hmrc-internal-manuals/<manual_slug>/<section_slug>"
        }

* `400`: the request JSON isn't well-formed.
* `409`: the slug is taken by content that is managed by another publishing tool.
* `422`: there's a validation error. A response body would detail the errors:

        {
          "status": "error",
          "errors": [
            "error_message_1",
            "error_message_2",
            ...
          ]
        }

* `503`: the request could not be completed because the API or the Publishing API is unavailable.

## Slugs, section IDs and URLs

GOV.UK has [URL standards](https://insidegovuk.blog.gov.uk/url-standards-for-gov-uk/)
to ensure that the URLs are SEO and user friendly.

This API constructs the GOV.UK URLs based upon the slugs and section IDs supplied to it.

Slugs are validated to ensure that they fit the GOV.UK styleguide according to these rules:

* only lowercase letters, numbers and dashes are allowed
* no leading or trailing dashes

Additionally, users of the API are required to follow the styleguide for slugs:

* slugs should not contain acronyms wherever possible
* dashes should be used to separate words
* articles (a, an, the) and other superfluous words should not be used
* URLs should use the verb stem where possible: eg `apply` instead of `applying`
* no multiple consecutive dashes

Section IDs are validated to ensure that they can be converted to slugs by simply making them lowercase.

## Markup

All `body` attributes in manuals or manual sections may contain
[Markdown in the Kramdown dialect](http://kramdown.gettalong.org/syntax.html).
The Markdown in those attributes is converted to HTML before the document is sent to the Publishing API.

There is a whitelist of allowed HTML tags and attributes. If a manual or a section
contains any disallowed HTML in any field, the request is rejected with a validation error (status code `422`).

The following tags are allowed:

```
a, abbr, b, bdo, blockquote, br, caption, cite, code, col, colgroup, dd, del, dfn, div, dl, dt, em, figcaption, figure, h1, h2, h3, h4, h5, h6, hgroup, hr, i, img, ins, kbd, li, mark, ol, p, pre, q, rp, rt, ruby, s, samp, small, strike, strong, sub, sup, table, tbody, td, tfoot, th, thead, time, tr, u, ul, var, wbr.
```

The following tag attributes are allowed, by tag:

* `:all=>["dir", "lang", "title", "id", "class"]`
* `"a"=>["href", "rel"]`
* `"blockquote"=>["cite"]`
* `"col"=>["span", "width"]`
* `"colgroup"=>["span", "width"]`
* `"del"=>["cite", "datetime"]`
* `"img"=>["align", "alt", "height", "src", "width"]`
* `"ins"=>["cite", "datetime"]`
* `"ol"=>["start", "reversed", "type"]`
* `"q"=>["cite"]`
* `"table"=>["summary", "width"]`
* `"td"=>["abbr", "axis", "colspan", "rowspan", "width"]`
* `"th"=>["abbr", "axis", "colspan", "rowspan", "scope", "width"]`
* `"time"=>["datetime", "pubdate"]`
* `"ul"=>["type"]`

### Images

Images are only allowed if on a relative path (ie hosted on `www.gov.uk`) or on
the GOV.UK assets domain: `assets.digital.cabinet-office.gov.uk`. Markup
containing images hosted on other domains will be rejected with a `422` error code.

On preview, the allowed image domains are expanded to include the preview
www.gov.uk domain `www.preview.alphagov.co.uk`) and the preview asset domain
(`assets-origin.preview.alphagov.co.uk`).

## Manual tags

Manuals can be tagged to topics on GOV.UK, so that they're easier for
users to find.

### How tagging works

Tags are mapped by their content IDs to manual slugs based on the topics each
manual refers to. This is done via the hardcoded CSV in
`lib/manuals_to_topics.csv`, from where the topic content IDs are sent
to the Publishing API, and the topic slugs are sent to Rummager. The CSV
contains three columns: Manual Slug, Topic Slugs, Topic IDs. A manual
can be tagged to multiple topics, and so the order of the content IDs has to
match with the order in which the topic slugs are specified.

There is a Rake task at `lib/tasks/manuals_to_topics.rake` to make the update
process less manual, for the hopefully rare occurrence that we might change
content IDs, or HMRC might change a manual's topics. It uses current data from
the content-register to get the content IDs for topic slugs, and regenerates the
entire CSV file with a `_regenerated` suffix for easy checking.

## Testing publishing in the GOV.UK development VM

You can use the JSON examples of requests for testing publishing in development,
for example with cURL from the root directory of the repository:

```
curl -i -XPUT -H'Authorization: Bearer faketoken' -H'Accept: application/json' \
  -H'Content-Type: application/json' --data-binary \
  @public/json_examples/requests/employment-income-manual.json \
  http://hmrc-manuals-api.dev.gov.uk/hmrc-manuals/test-manual
```

Or with [HTTPie](https://github.com/jkbrzt/httpie):

```
http PUT http://hmrc-manuals-api.dev.gov.uk/hmrc-manuals/test-manual \
  Authorization:'Bearer faketoken' Accept:application/json Content-Type:application/json \
  < public/json_examples/requests/employment-income-manual.json
```

In development mode the API doesn't require a valid bearer token; any value is
accepted. To test publishing to our Preview or Staging environments you would
need a real token for the right environment.
