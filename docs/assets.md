# [DRAFT] Managing assets

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

## Request
  
```http
POST /assets
```

### Request parameters

| Parameter               | Required | Description                                                         |
| ----------------------- | -------- | ------------------------------------------------------------------- |
| `asset[file]`           | Yes      | File to upload.                                                     |

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
{
  "_response_info": { "status": "success" },
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://draft-assets.integration.publishing.service.gov.uk/media/6a216e0509c4d5e2e98bd731/logo.png?token=eyJhbGciOiAIUzI1PiJ9.eyJzdWIiOiJkYmU3NmNiZC1kNmUjLTQzODItODA4OC01NDdkZGZiMzcwMWUiLCJjb250ZW50X2lkIjoiMmU0MDU3NTQtNTI1ZS00MjQ2LWJmZjgtYmI4ZjkwNzBiNTM4IiwiaWF0IjoxNzgxMDgxMjEwLCJleHAiOjE3ODM2NzMyMHB9.Uvqe1aHgGp_wxCTIyXMNB8COwBo9frs2l2SskZTBJ_Q",
  "state": "unscanned",
  "draft": true,
  "deleted": false,
  "preview_expiry": "2026-07-10T08:31:14Z", //  30 days after creation or when asset is published
}
```

#### Accessing draft assets

Draft assets are not publicly accessible and are hosted on https://draft-assets.publishing.service.gov.uk/ domain.

The `file_url` returned in the asset response includes a time-limited access token and can be used directly to retrieve the asset:

```http
GET https://draft-assets.publishing.service.gov.uk/media/659bee95614fa20014f3a9f7/logo.png?token=<jwt-token>
```

If the access token is valid, the draft asset will be served. Otherwise, access will be denied.
Access tokens expire 30 days after they are issued or when asset is published, whichever occurs first. A new token can be regenerated using the `POST /assets/:id/regenerate-access` endpoint.

### Error responses

| Status                     | Description                           |
| -------------------------- | ------------------------------------- |
| `401 Unauthorized`         | Authentication failed.                |
| `413 Payload Too Large`    | Uploaded file exceeds permitted size. |
| `422 Unprocessable Entity` | Asset could not be created.           |

---

# Regenerate draft asset access

Resets and generates a new preview link for a draft asset and returns an updated preview URL.

Draft asset access tokens expire 30 days after they are issued. Use this endpoint to generate a new token when the existing token has expired or is about to expire.

The response includes a refreshed `file_url` containing the new token and an updated `preview_expiry` timestamp.
This operation will disable the previous preview link.

## Request
  
```http
POST /assets/{asset-id}/regenerate-access
```

### Path parameters

| Parameter  | Description                     |
| ---------- | ------------------------------- |
| `asset-id` | Unique identifier of the asset. |

### Success response

```http
201 Created
```

```json
{
  "_response_info": { "status": "success" },
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "file_url": "https://draft-assets.integration.publishing.service.gov.uk/media/6a216e0509c4d5e2e98bd731/logo.png?token=eyJhbGciOiAIUzI1PiJ9.eyJzdWIiOiJkYmU3NmNiZC1kNmUjLTQzODItODA4OC01NDdkZGZiMzcwMWUiLCJjb250ZW50X2lkIjoiMmU0MDU3NTQtNTI1ZS00MjQ2LWJmZjgtYmI4ZjkwNzBiNTM4IiwiaWF0IjoxNzgxMDgxMjEwLCJleHAiOjE3ODM2NzMyMHB9.Uvqe1aHgGp_wxCTIyXMNB8COwBo9frs2l2SskZTBJ_Q",
  "preview_expiry": "2026-08-10T08:31:14Z",
}
```

### Error responses

| Status                     | Description                           |
| -------------------------- | ------------------------------------- |
| `401 Unauthorized`         | Authentication failed.                |
| `404 Not Found`            | Asset does not exist.                 |
| `422 Unprocessable Entity` | Access couldn't be regenerated        |

---

# Replace existing asset

Replaces the file associated with an existing asset while retaining the asset identifier via the update endpoint.

## Request

```http
PUT /assets/{asset-id}
```

### Path parameters

| Parameter  | Description                     |
| ---------- | ------------------------------- |
| `asset-id` | Unique identifier of the asset. |

### Request parameters

| Parameter     | Required | Description       |
| ------------- | -------- | ----------------- |
| `asset[file]` | Yes      | Replacement file. |

### Success response

```http
200 OK
```

```json
{
  "_response_info": { "status": "ok" },
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "name": "updated-logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/6a216e0509c4d5e2e98bd731/updated-logo.png",
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

# Publish draft asset

Makes a draft asset publicly available via the update endpoint.

## Request

```http
PUT /assets/{asset-id}
```

### Path parameters

| Parameter  | Description                     |
| ---------- | ------------------------------- |
| `asset-id` | Unique identifier of the asset. |

### Request parameters

| Parameter        | Required | Description                                 |
| ---------------- | -------- | ------------------------------------------- |
| `asset[draft]`   | Yes      | Must be `false` to publish the draft asset. |


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

# Delete asset

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

# Restore deleted asset

Restores a previously deleted asset.

## Request

```http
PATCH /assets/{asset-id}/restore
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
| `409 Conflict`  | Asset is already published.      |

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

| Status          | Description                                        |
| --------------- | -------------------------------------------------- |
| `403 Forbidden` | You don't have permission to access this resource. |
| `404 Not Found` | Asset does not exist.                              |

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

| Status          | Description                                        |
| --------------- | -------------------------------------------------- |
| `403 Forbidden` | You don't have permission to access this resource. |
| `404 Not Found` | Asset does not exist.                              |
| `410 Gone`      | Asset has been deleted.                            |
