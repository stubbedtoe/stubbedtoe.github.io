# A Jekyll-powered portfolio site
## [andrewhealy.com](http://www.andrewhealy.com)

I wanted to create a simple and fast static portfolio site using easily maintainable, developer-friendly technologies. Having complete control over every aspect of my site was important too. [Jekyll](http://jekyllrb.com) provides for the use of SASS, Coffeescript, Markdown, templating etc. and Jekyll sites are very simple to host (for free) on [Github Pages](https://pages.github.com/). Sounds good.

This site makes judicious use of Javascript (for Ajax and image gallery loading, for example) but it also makes a significant effort to provide the same fuctionality to users with Javascript turned off. The image galleries are still a work in progress though.

### Using this repository for your own site

The following are some points you'll probably want to know if you're to use this project for your own portfolio site:

* __Projects__: Each project lives in the `_projects` folder.
 * Each project should be named uniquely. The project's `id` attribute should be identical. This is different to the `name` attribute (which is what is displayed - it can be duplicated across projects)
 * It is assumed that the thumbnail image (the one on the homepage) for the project is named `thumb.jpg`. If it is named anything else, let Jekyll know by using the `thumb` attribute in the project's YAML front-matter eg: `thumb: thumb.gif`
 * If you want to keep the project but not have it appear on your site, move it to the `no_publish` folder in `_projects` (which is ignored by Jekyll).
* __Images__:
 * Wherever you are hosting your images (I store mine with the [Amazon S3](https://aws.amazon.com/s3/) service as the `amazon_url` attribute in `_config.yml` shows), there must be a folder for each project named with the project's `id`.
 * Inside this folder, you need three folders named `thumb` (where the thumbnail lives), `medium` (which contains the standard-sized images used by the inline image gallery) and `full`(which contains the large versions of the images used when the image gallery is fullscreen)
* __Filters/Categories__:
 * Each project should belong to one or more category (for example `personal`, `web`, `print`, etc) and these should be specified by the project's `categories` YAML array.
 * Each category should have a page in the `_filter` folder. This is primarily for users without Javascript. The important part here is passing the category name to the `project_list.html` template: eg `active='commercial'`

`usekraken.py` and `upload_files.py` are python scripts to make life easier. I used [Kraken](https://kraken.io) to optimise my images and as a bonus the API allows uploading to Amazon S3. The other script automates uploading to a server (not necessary if Github is providing your hosting...). Both these scripts look for values such as usernames and passwords from `configuration.json`. I have not included this file for obvious reasons.  

### Acknowledgements

* Image galleries by [Fotorama](http://fotorama.io/)
* Icons by [Font Awesome](https://fortawesome.github.io/Font-Awesome/)
* Arvo on [Google Fonts](https://www.google.com/fonts)
