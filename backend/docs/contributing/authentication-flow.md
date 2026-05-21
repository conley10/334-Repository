# How to use User Identity

When a user is logged in, we need to know who they are so we can save their bookings and vehicles. This guide explains how the app finds that information.

## 1. Getting the Token
1.  **Login:** The user sends their email and password to `POST /auth/token`.
2.  **The Token:** The server gives back a digital "ID card" called a token (**JWT**).
3.  **Sending the Token:** Every time the user asks for something (like a list of their cars), they send this token in the background (**Authorization Header**).

## 2. What happens inside the Server?
When the request arrives:
1.  **Check:** The server checks if the token is real and hasn't expired (**Authentication Middleware**).
2.  **Read:** The server reads the user's ID and Role stored inside the token (**Claims**).
3.  **Save:** The server saves this information in a temporary "bucket" for that specific request (**HttpContext**).
4.  **Verify:** The server checks if the user is allowed to see the page (**[Authorize]** attribute).

## 3. How to get the User ID in your code
You don't need to read the token yourself. We use a service called **`ICurrentUserService`**.

### Example:
If you are writing code for Bookings, just add the user service to your constructor:

```csharp
public class BookingsService
{
    private readonly ICurrentUserService _userService;

    public BookingsService(ICurrentUserService userService)
    {
        _userService = userService;
    }

    public void CreateBooking() 
    {
        // Get the ID of the person making the request
        int? userId = _userService.UserId; 
        
        // If they aren't logged in, userId will be null
        if (userId == null) return;
        
        // Save the booking for this user...
    }
}
```

## 🛠️ Testing without Login (Mock Mode)
While we are developing, we use a "Master Switch" called **BYPASS_AUTH** in the Docker settings.
*   **Always On:** When this is true, the app pretends everyone is a "Super User" (UserID: 2) with **all roles** enabled (Admin, Student, and Staff).
*   **Why?** This lets you test your code immediately without needing a real login token.
