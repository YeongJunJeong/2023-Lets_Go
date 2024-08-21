from django.contrib import admin
from .models import Place, Tag, Review

admin.site.register(Place)
admin.site.register(Tag)
admin.site.register(Review)