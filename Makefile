JEKYLL_VERSION=3.8
PORT=8080

serve:
	docker run --volume="${CURDIR}:/srv/jekyll" -p ${PORT}:4000 -it jekyll/jekyll:${JEKYLL_VERSION} jekyll s --watch --livereload