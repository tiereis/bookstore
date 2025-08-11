from rest_framework import serializers

from products.models import Product
from products.serializers.product_serializer import ProductSerializer

class OrderSerializer(serializers.Serializer):
    product = ProductSerializer(required=True, many=True)
    total = serializers.SerializerMethodField()

    def get_total(self, instance):
        total = sum([product.price for product in instance.product.all()])
        return total
    
    class Meta:
        model = Product
        fields = ['product', 'total']