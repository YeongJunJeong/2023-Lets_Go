"""
URL configuration for config project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include

from rest_framework import routers

from .views import ScheduleApiView, PlanViewSet, ChatAPIView, ChatHistoryAPIView, DailyRecommandApiView, ScheduleDeleteView

namespace = "plan"

router_plan = routers.DefaultRouter()
router_plan.register(r"plan", PlanViewSet)

urlpatterns = [
    path("schedule/", ScheduleApiView.as_view()),
    path(r'', include(router_plan.urls)),
    path('recommand', ChatAPIView.as_view()),
    path('chathistory', ChatHistoryAPIView.as_view()),
    path('dailyrecommand', DailyRecommandApiView.as_view()),
    path('schedule/delete', ScheduleDeleteView.as_view()),
]
