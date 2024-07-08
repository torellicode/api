## Torelli API
This API was built by Christian Torelli and is intended to showcase abilities in API devlopment using Ruby on Rails.<br>
Built using Ruby version 3.2.2 and Rails verison 7.1.3.4
<br>

### Features
- **User Tokens** - Encryption/decryption similar to JWT
- **Sessions** - Creating a new session will provide a token
- **Users** - Creating a new user begins a session and provide a token
- **Articles** - 20 articles are created upon user creation to test pagination
- **Error Handling**
- **Serialization**
- **Pagination**
- **Tests**
<br>

# Usage
### Base URL
All requests should be made to the following base URL:<br>
https://torelli-api-e68f6795f068.herokuapp.com

## Endpoints
### **Users**
#### Create User
- **Endpoint**: `/api/v1/users`
- **Method**: `POST`
- **Body**: raw JSON
    ```json
    {
      "user": {
        "email": "test@example.com",
        "password": "password123",
        "password_confirmation": "password123"
      }
    }
    ```
### **You will recieve your token in the response body. <u>Keep this token for all future requests</u>**

#### Fetch user data
- **Endpoint**: `/api/v1/users/data`
- **Method**: `GET`
- **Headers**: `Authorization: Bearer <token>`

#### Update User
- **Endpoint**: `/api/v1/users/:user_id`
- **Method**: `PUT`
- **Body**: raw JSON
  ```
  {
    "user": {
      "email": "email@example.com",
      "password": "password123",
      "password_confirmation": "password123"
    }
  }
  ```
- **Headers**: `Authorization: Bearer <token>`

#### Delete User
- **Endpoint**: `/api/v1/users/:user_id`
- **Method**: `DELETE`
- **Headers**: `Authorization: Bearer <token>`
<br>

### **Sessions**
#### Login
- **Endpoint**: `/api/v1/login`
- **Method**: `POST`
- **Body**: raw JSON
    ```json
    {
      "email": "email@example.com",
      "password": "password123"
    }
    ```
### **You will recieve your token in the response body. Keep this token for all future requests**
It may benefit you to also note your id

#### Logout
- **Endpoint**: `/api/v1/logout`
- **Method**: `DELETE`
- **Headers**: `Authorization: Bearer <token>`
<br>

### **Articles**
#### Create article
- **Endpoint**: `/api/v1/articles`
- **Method**: `POST`
- **Body**: raw JSON
    ```json
    {
        "article": {
            "title": "Example title",
            "content": "Example content"
        }
    }
    ```
- **Headers**: `Authorization: Bearer <token>`

#### Articles index
- **Endpoint**: `/api/v1/articles`
- **Method**: `GET`
- **Headers**: `Authorization: Bearer <token>`
- **Params**: (optional for pagination)
  ```
    Key: page
    Value: 1

    Key: per_page
    Value: 10
  ```

#### Fetch an article
- **Endpoint**: `/api/v1/articles/:article_id`
- **Method**: `GET`
- **Headers**: `Authorization: Bearer <token>`

#### Update article
- **Endpoint**: `/api/v1/articles/:article_id`
- **Method**: `PUT`
- **Body**: raw JSON
    ```json
    {
        "article": {
            "title": "This is the updated article title",
            "content": "Updated content is much shorter"
        }
    }
    ```
- **Headers**: `Authorization: Bearer <token>`

#### Delete article
- **Endpoint**: `/api/v1/articles/:article_id`
- **Method**: `DELETE`
- **Headers**: `Authorization: Bearer <token>`
<br>


### Planned updates
- improve error handeling for sessions and articles
- edge case error handling
- robust and efficient test suite