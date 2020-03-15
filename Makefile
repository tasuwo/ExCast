TEST_HELPER_TARGET     := SharedTestHelper

SWIFT_FORMAT           := ./Pods/SwiftFormat/CommandLineTool/swiftformat
SWIFT_FORMAT_CONFIG    := .swiftformat
FORMAT_TARGETS         := ExCast ExCastTests ExCastUIKit ExCastUIKitTests Domain DomainTests Infrastructure InfrastructureTests Common CommonTests SharedTestHelper
FORMAT_EXCLUDE_TARGETS := Pods

SWIFT_LINT             := ./Pods/SwiftLint/swiftlint

SOURCERY               := ./Pods/Sourcery/bin/sourcery

generate: generate_mocks generate_persistable ## 各種コード自動生成を行う

generate_mocks: ## モックを自動生成する
	@mockolo -s ./Domain -d $(TEST_HELPER_TARGET)/Mocks/Domain/DomainMocks.swift -i Domain
	@mockolo -s ./Infrastructure -d $(TEST_HELPER_TARGET)/Mocks/Infrastructure/InfrastructureMocks.swift -i Infrastructure

generate_persistable: ## InfrastructureレイヤのPersistableモデル群を生成する
	@$(SOURCERY) --sources . --templates templates/Persistable.swifttemplate --output ./Infrastructure/Service/Model/

fix: swiftlint_fix ## コードの自動修正を行う

swiftlint_fix:
	$(SWIFT_LINT) autocorrect --format

lint: swiftlint_lint ## 各種lintを行う

swiftlint_lint: ## swiftlintによるリントを実行する
	$(SWIFT_LINT)

format: swiftformat_format ## 各種フォーマッターをかける

swiftformat_format: ## swiftformatによるフォーマッターをかける
	$(SWIFT_FORMAT) --config $(SWIFT_FORMAT_CONFIG) --swiftversion 5 --exclude $(FORMAT_EXCLUDE_TARGETS) $(FORMAT_TARGETS)

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: format swiftformat_format generate generate_mocks lint swiftlint_lint help

.DEFAULT_GOAL := help
