from django.db import models

from datetime import datetime
from django.utils import timezone
from django.db.models.functions import Lower


# Create your models here.
TITLE_LENGTH = 200
DESCR_LENGTH = 1000
NAME_LENGTH = 20
INSTR_LENGTH = 20
ADDRESS_LENGTH = 50


class Instrument(models.Model):
    name = models.CharField(max_length=NAME_LENGTH)

class Performer(models.Model):
    first_name = models.CharField(max_length=NAME_LENGTH)
    middle_name = models.CharField(max_length=NAME_LENGTH)
    family_name = models.CharField(max_length=NAME_LENGTH)
    instruments = models.ManyToManyField(Instrument)
    class Meta:
        constraints = [
            models.UniqueConstraint(fields=['family_name','middle_name','family_name'], name='unique performer name')
        ]

class AgendaItem(models.Model):
    title = models.CharField(max_length=TITLE_LENGTH)
    description = models.CharField(max_length=DESCR_LENGTH)
    # token = models.CharField(max_length=TOKEN_LENGTH, unique=True)
    item_date = models.DateTimeField(
        'item date', default=timezone.make_aware(datetime(1900, 1, 1)))
    lineUp = models.ManyToManyField(Performer)
    location = models.CharField(max_length=ADDRESS_LENGTH)


    def __str__(self):
        return self.title
