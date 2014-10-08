run:
	grunt serve

build:
	grunt

install:
	npm install
	./node_modules/.bin/bower install
	grunt wiredep

deploy:
	grunt --force deploy

publish:
	git branch -D public || true
	git checkout --orphan public
	git add -A
	git commit -am "Auto commit"
	git push --force git@github.com:Pirhoo/gw-greatripoffmap.git public:master
	git checkout master

prefetch:
	node prefetch.js --output app/json/data.companies.json --type company
	node prefetch.js --output app/json/data.cases.json --type case
