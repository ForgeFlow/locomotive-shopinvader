module ShopInvader
  module Liquid
    module Drops
      ONLY_SESSION_STORE = %w(last_sale notifications maintenance cart)
      ONLY_ONE_TIME = %w(notifications maintenance)
      # Examples:
      #
      # {{ store.category.size }}
      #
      # with_scope
      #
      # {{ store.category.all | paginate: per_page: 2, page: params.page }}
      # {{ store.category | find: '42' }}
      # {{ store.category.all | where: name: 'something' }}
      # {{ store.category.all | where: rating_value }}
      #
      class Store < ::Liquid::Drop

        def before_method(meth)
          if ONLY_SESSION_STORE.include?(meth)
            data = service.erp.is_cached?(meth) && service.erp.read_from_cache(meth)
            if ONLY_ONE_TIME.include?(meth)
              service.erp.clear_cache(meth)
            end
            data
          elsif store[meth]
            read_from_site(meth)
          elsif is_elastic_collection?(meth)

            Locomotive::Common::Logger.debug "[Elastic] using elastic collection"
            ElasticCollection.new(meth)
          elsif is_algolia_collection?(meth)
            AlgoliaCollection.new(meth)
          elsif is_plural?(meth)
            ErpCollection.new(meth)
          else
            ErpItem.new(meth)
          end
        end

        private

        def is_plural?(value)
          value.singularize != value
        end

        def is_elastic_collection?(name)
          service.elastic.indices.any? { |index| index['name'] == name }
        end

        def is_algolia_collection?(name)
          service.algolia.indices.any? { |index| index['name'] == name }
        end

        def service
          @context.registers[:services]
        end

        def read_from_site(meth)
          # Exemple of configuration of store
          # that allow to use store.available_countries
		  # _store:
          #     available_countries: >
          #         {"fr": [
          #             { "name": "France", "id": 74 },
          #             { "name": "Belgique", "id": 20 },
          #             { "name": "Espagne", "id": 67 }
          #             ]
          #         }
          data = JSON.parse(store[meth])
          if data.is_a?(Hash) and data[locale]
            data[locale]
          else
            data
          end
        end

        def store
          @store ||= @context.registers[:site].metafields[:_store] || {}
        end

        def locale
          @locale ||= @context.registers[:locale].to_s
        end
      end

    end
  end
end
