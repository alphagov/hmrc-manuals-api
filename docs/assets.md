# [DRAFT for internal review]

> :warning: NOTE
> Implementation of access limiting / auth bypass IDs maybe out of scope for the MVP

> As a workaround HMRC could potentially login to Signon, download the file and email it to the person who needs to review it but doesn't have access to Signon.

# Managing assets

The assets endpoints allow clients to upload, replace, delete, publish, restore and retrieve assets associated with HMRC manuals.

## Common headers

### Request headers

| Header          | Required | Description                                                  |
| --------------- | -------- | ------------------------------------------------------------ |
| `Authorization` | Yes      | Bearer token used to authenticate the request.               |
| `Content-Type`  | No       | Defaults to `application/json`.                              |
| `Accept`        | No       | Defaults to `application/json`.                              |

### Response headers

| Header         | Description                                                 |
| -------------- | ----------------------------------------------------------- |
| `Content-Type` | `application/json`                                          |

---

# Upload new asset

Uploads a new asset after a clean virus scan result and creates a draft asset record.

> REVIEW QUESTIONS
> - Do we want to give the consumers the option to set asset to draft or do we enforce draft on first upload?
> - Should we introduce 413 Payload Too Large response for uploads?
> - Which subset of Asset Manager response fields (asset manager ID, file URL, state, replacement metadata, draft status, etc.) should be exposed through the HMRC Manuals API?

## Request
  
```http
POST /assets
```

### Form parameters

| Parameter               | Required | Description                                                         |
| ----------------------- | -------- | ------------------------------------------------------------------- |
| `asset[file]`           | Yes      | File to upload.                                                     |
| `asset[access_limited]` | TBC      | Whether access should be restricted. Defaults to HMRC organisation. |
| `asset[draft]`          | No       | Whether the asset should remain in draft state. Defaults to `true`. |

### Example request

```bash
curl -X POST \
  http://hmrc-manuals-api.dev.gov.uk/assets \
  -H "Authorization: Bearer <token>" \
  -F "asset[file]=@logo.png"
```

### Success response

```http
201 Created
```

```json
# See: https://github.com/alphagov/asset-manager/blob/main/app/presenters/asset_presenter.rb
{
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/659bee95614fa20014f3a9f7/logo.png",
  "state": "unscanned",
  "draft": true,
  "deleted": false,
}
```

### Error responses

| Status                     | Description                           |
| -------------------------- | ------------------------------------- |
| `401 Unauthorized`         | Authentication failed.                |
| `413 Payload Too Large`    | Uploaded file exceeds permitted size. |
| `422 Unprocessable Entity` | Asset could not be created.           |

# Replace existing asset

Replaces the file associated with an existing asset while retaining the asset identifier.

> REVIEW QUESTIONS
> - Is there a need to also redirect assets?

## Request

```http
PUT /assets/{asset-id}
```

### Path parameters

| Parameter  | Description                     |
| ---------- | ------------------------------- |
| `asset-id` | Unique identifier of the asset. |

### Form parameters

| Parameter     | Required | Description       |
| ------------- | -------- | ----------------- |
| `asset[file]` | Yes      | Replacement file. |

### Success response

```http
200 OK
```

```json
{
  "_response_info": { "status": "success" },
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "name": "updated-logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/659bee95614fa20014f3a9f7/updated-logo.png",
  "state": "unscanned",
  "draft": true,
  "deleted": false,
}
```

### Error responses

| Status                     | Description               |
| -------------------------- | ------------------------- |
| `404 Not Found`            | Asset does not exist.     |
| `422 Unprocessable Entity` | Asset replacement failed. |

---

# Delete asset

> REVIEW QUESTIONS
> - Should success response be 200 OK like in Asset Manager or 204 No Content?

Marks an asset as deleted.

## Request

```http
DELETE /assets/{asset-id}
```

### Success response

```http
200 OK
```

```json
{
  "_response_info": { "status": "success" },
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "name": "updated-logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/659bee95614fa20014f3a9f7/updated-logo.png",
  "state": "uploaded",
  "draft": false,
  "deleted": true,
}
```

### Error responses

| Status          | Description                                   |
| --------------- | --------------------------------------------- |
| `404 Not Found` | Asset does not exist.                         |
---

# Publish draft asset

Makes a draft asset publicly available.

> Note: We don't have draft documents, they are immediately published https://github.com/alphagov/hmrc-manuals-api/blob/132edd90bce8061be40bef711ac40510a562f969/app/notifiers/publishing_api_notifier.rb#L6-L11 It may note be straight forward to automatically publish drafts assets associated with the draft document.
> It will use Asset Managers Update endpoint

> REVIEW QUESTIONS
> - Should this be a separate endpoint or can we have Update asset endpoint that would allow users to update file and state based on params?

## Request

```http
PATCH /assets/{asset-id}/publish
```

### Success response

```http
200 OK
```

```json
{
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/659bee95614fa20014f3a9f7/logo.png",
  "state": "uploaded",
  "draft": false,
  "deleted": false,
}
```

### Error responses

| Status                      | Description                  |
| --------------------------- | ---------------------------- |
| `404 Not Found`.            | Asset does not exist.        |
| `422 Unprocessable Entity`  | Asset couldn't be published. |

---

# Restore deleted asset

Restores a previously deleted asset.

> REVIEW QUESTIONS
> - Should we add `409 Conflict`  | Asset is already published error response?
> - Should restore be POST or PATCH?

## Request

```http
POST /assets/{asset-id}/restore
```

### Success response

```http
200 OK
```

```json
{
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/659bee95614fa20014f3a9f7/logo.png",
  "state": "uploaded",
  "draft": false,
  "deleted": false,
}
```

### Error responses

| Status          | Description                      |
| --------------- | -------------------------------- |
| `404 Not Found` | Asset does not exist.            |

---

# (Optional, if needed) Get asset information

Returns metadata for an asset.

## Request

```http
GET /assets/{asset-id}
```

### Success response

```json
{
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/659bee95614fa20014f3a9f7/logo.png",
  "state": "uploaded",
  "draft": false,
  "deleted": false,
}
```

### Error responses

| Status          | Description           |
| --------------- | --------------------- |
| `403 Forbidden` | You don't have permission to access this resource. |
| `404 Not Found` | Asset does not exist. |

---

# (Optional, if needed) Download asset

Returns the binary contents of an asset.

## Request

```http
GET /assets/{asset-id}/download
```

### Success response

```http
200 OK
```

Binary file content.

### Error responses

| Status          | Description             |
| --------------- | ----------------------- |
| `403 Forbidden` | You don't have permission to access this resource. |
| `404 Not Found` | Asset does not exist.   |
| `410 Gone`      | Asset has been deleted. |

