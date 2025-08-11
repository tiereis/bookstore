from rest_framework import serializers

from product.models.product import Product
from product.serializers.category_serializer import CategorySerializer

class ProductSerializer(serializers.ModelSerializer):
    category = CategorySerializer(required=True, many=True)
    
    class Meta:
        model = Product
        fields = ['title', 'description', 'price', 'active', 'category']

    def create(self, validated_data):
            category_data = validated_data.pop("categories_id")

            product = Product.objects.create(**validated_data)
            for category in category_data:
                product.category.add(category)

            return product