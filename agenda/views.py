from django.shortcuts import render
from django.http import HttpResponse, HttpResponseRedirect

# Create your views here.


def index_view(request):
    return HttpResponse('fottiti')