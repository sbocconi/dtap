from django.urls import path, re_path

from . import views

app_name = 'agenda'

urlpatterns = [
    path('', views.index_view, name='index'),
]
