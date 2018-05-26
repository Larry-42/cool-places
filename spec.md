# Specifications for the Sinatra Assessment

Specs:
- [x] Use Sinatra to build the app--App runs on Sinatra
- [x] Use ActiveRecord for storing information in a database--App uses ActiveRecord for models.
- [x] Include more than one model class (list of model class names e.g. User, Post, Category)--has User, Place, and Comment models.
- [x] Include at least one has_many relationship on your User model (x has_many y, e.g. User has_many Posts)--a User has_many Comments and has_many Places, while a Place has_many Comments
- [x] Include at least one belongs_to relationship on another model (x belongs_to y, e.g. Post belongs_to User)--a Place belongs_to a User, while a Comment belongs_to a User and belogns_to a Comment
- [x] Include user accounts--The User model enables login, logout, and content CRUD functionality
- [x] Ensure that users can't modify content created by other users--the Controllers guard against modify any data that does not belong to the current User
- [x] Ensure that the belongs_to resource has routes for Creating, Reading, Updating and Destroying--Both Place and Comment models include CRUD functionality.
- [x] Include user input validations--the Controllers validate user input
- [x] Display validation failures to user with error message (example form URL e.g. /posts/new)--rack-flash is used to provide error messages
- [x] Your README.md includes a short description, install instructions, a contributors guide and a link to the license for your code--It includes a short description, install instructions, and information on the LICENSE and contributing files in this repository.

Confirm
- [x] You have a large number of small Git commits
- [x] Your commit messages are meaningful
- [x] You made the changes in a commit that relate to the commit message
- [x] You don't include changes in a commit that aren't related to the commit message
