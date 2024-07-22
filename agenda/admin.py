from django.contrib import admin

# Register your models here.

from .models import Instrument, Performer, AgendaItem

admin.site.register(Instrument)
admin.site.register(Performer)
admin.site.register(AgendaItem)