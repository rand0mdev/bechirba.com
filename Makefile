build:
	$(MAKE) prepare-tests
	$(MAKE) analyze
	$(MAKE) tests

.PHONY: tests
tests:
	$(MAKE) prepare-tests
	php vendor/bin/simple-phpunit

analyze: vendor
	yarn audit
	composer valid
	php bin/console doctrine:schema:validate

	# Linter
	php bin/console lint:yam config
	php bin/console lint:container
	php bin/console lint:twig templates
	php bin/console lint:xliff translations

	# PHP CS Fixer
	php vendor/bin/phpcs --exclude=Generic.Files.LineLength

.PHONY: translations
translations:
	php bin/console translation:update fr --force
	php bin/console translation:update en --force

prepare-dev: bin
	yarn install
	yarn dev
	composer install --no-progress --prefer-dist
	php bin/console doctrine:database:drop --if-exists -f -n --env=dev
	php bin/console doctrine:database:create --env=dev
	php bin/console doctrine:schema:update -f --env=dev
	php bin/console doctrine:fixtures:load -n --env=dev

prepare-tests: bin
	yarn install
	yarn build
	composer install --no-progress --prefer-dist
	php bin/console cache:clear --env=test
	php bin/console doctrine:database:drop --if-exists -f -n --env=test
	php bin/console doctrine:database:create --env=test
	php bin/console doctrine:schema:update -f --env=test
	php bin/console doctrine:fixtures:load -n --env=test
