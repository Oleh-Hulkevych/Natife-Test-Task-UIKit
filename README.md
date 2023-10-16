### Natife Test Task / UIKit

***

![natife-test-task-cover](https://github.com/Oleh-Hulkevych/Natife-Test-Task-UIKit/assets/109086187/c1e7f6b3-639b-4e8c-a802-f6370cf4ce4b)

***

Posts / A small test task (application) for Native that downloads data from the server in JSON format and publishes it to the user. / Something like an Instagram app.

The first screen displays a list view of the posts and a sort button on top that locally sorts our list by date and rating in descending order. So that you know, the order of posts is set by the server by default at the start of the program or if you reload the tape by pulling it.

Each cell displays the name of the post, its short description, the number of added likes, and the date the post was published or the number of days if the post was published less than a month ago.

The post cell is dynamic and by default only displays a short description of the post, which can contain no more than two lines of text. However, we can expand the cell to see a short description of the post and optionally collapse the cell to its previous state or go to a detailed view of the post by clicking on the cell.

> Note: Expanded cells never lose their state (only when restarting the application).

The second screen displays complete information about the post: picture, title, full description of the post, number of likes, and date of publication.

On the first and second screens, you also have the option to add or subtract likes.

> Note: Liked posts also never lose their state (only when restarting the application).

***

Used stack:

Swift / UIKti / Auto Layout / HIG / MVC / URLSession / SDWebImage.

Also, iOS 14 or higher is supported.

***

Thanks for reading this far! :smile:

Have a nice day & happy coding! :wink:

***
