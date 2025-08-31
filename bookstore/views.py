from django.http import HttpResponse
from django.template import loader
from django.views.decorators.csrf import csrf_exempt

def hello_world(request):
    template = loader.get_template('hello_world.html')
    return HttpResponse(template.render())