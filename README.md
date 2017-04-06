# HMRC Manuals API

This app provides URLs for pushing HMRC manuals to the GOV.UK Publishing API.

## Nomenclature

- **Manual**: HMRC manual with title and description, contains many Sections. See [Adding or updating a manual](docs/extended_documentation.md#adding-or-updating-a-manual) for more details

- **Section**: Sections can contain sub-sections and/or a content body. See [Adding or updating a section](docs/extended_documentation.md#adding-or-updating-a-manual-section) for more details

## Technical documentation

Provides an API for a system built by HMRC to publish tax manuals onto GOV.UK. In many ways it is analogous to a backend/admin app for publishing on GOV.UK. Content which passes validation and checks for unsanitary content is submitted to the GOV.UK Publishing API application. The application does not have a database itself. An HMRC manual consists of two document types: the manual itself and manual sections.

See the [extended documentation](docs/extended_documentation.md) for details:

- [Connecting to the API](docs/extended_documentation.md#connecting-to-the-api)
- [Adding or updating a manual](docs/extended_documentation.md#adding-or-updating-a-manual)
- [Adding or updating a section](docs/extended_documentation.md#adding-or-updating-a-manual-section)
- [Responses to PUT requests](docs/extended_documentation.md#possible-responses-to-put-requests)
- [Slugs, Section Ids and Urls](docs/extended_documentation.md#slugs-section-ids-and-urls)
- [Content Ids](docs/extended_documentation.md#content-ids)
- [Markup](docs/extended_documentation.md#markup)
- [Manual Tags](docs/extended_documentation.md#manual-tags)
- [Removing published manuals](docs/extended_documentation.md#removing-published-manuals)
- [Testing publishing in the GOVUK dev vm](docs/extended_documentation.md#testing-publishing-in-the-govuk-development-vm)
- [Managing manuals and sections with rake](docs/extended_documentation.md#managing-manuals-and-sections-with-rake)

### Dependencies

- [alphagov/rummager](https://github.com/alphagov/rummager): allows documents to be indexed for searching in both Finders and site search
- [alphagov/publishing-api](https://github.com/alphagov/publishing-api): allows documents to be published to the Publishing queue

### Running the application

`./startup.sh`

This runs `bundle install` to install dependencies and runs the app on port `3071`. 

When using the GOV.UK development VM use `bowl hmrc-manuals-api` in the Dev VM `development` directory. The app will be available at http://hmrc-manuals-api.dev.gov.uk/.

### Running the test suite

`bundle exec rake`

### Any deviations from idiomatic Rails/Go etc.

The application does not have a database itself, it sends on requests to the Publishing API and Rummager.

### Example API output

[Responses to PUT requests](docs/extended_documentation.md#possible-responses-to-put-requests)

## Licence

[MIT License](LICENCE)
