from django.shortcuts import render

from rest_framework import generics, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet
from rest_framework.generics import GenericAPIView
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework import routers

from places.serializers import PlaceModelSerializer
from places.models import Place
from .serializers import ScheduleModelSerializer, PlanModelSerializer, ScheduleCreateSerializer, ChatSerializer, ChatDbSerializer, ScheduleDeleteSerializer
from .models import Schedule, Plan, chatDb
import main_model
import re
import pandas as pd
from random import choice, shuffle

# Create your views here.

class ScheduleApiView(GenericAPIView):
    serializer_class = ScheduleCreateSerializer

    def post(self, request):
        serializer = self.get_serializer(data = request.data)
        start_date = request.data.get('start_date')
        end_date = request.data.get('end_date')
        place = request.data.get('place')
        plan = request.data.get('plan')

        if start_date > end_date:
            return Response({'error' : '올바른 시간을 입력하세요.'}, status=status.HTTP_400_BAD_REQUEST)
        else:
            if serializer.is_valid():
                data = {
                    "start_date" : start_date,
                    "end_date" : end_date,
                    "place" : place,
                    "plan" : plan
                }
                serializer.save()
                return Response(data, status=status.HTTP_201_CREATED)
            else:
                return Response(serializer.errors, status=400)
    def patch(self, request):
        serializer = self.get_serializer(data=request.data, partial=True)
        if serializer.is_valid():
            start_date = serializer.validated_data.get('start_date')
            end_date = serializer.validated_data.get('end_date')

            if start_date and end_date and start_date > end_date:
                return Response({'error': '올바른 시간을 입력하세요.'}, status=status.HTTP_400_BAD_REQUEST)

            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ScheduleDeleteView(GenericAPIView):
    serializer_class = ScheduleDeleteSerializer

    def delete(self, request):
        serializer = self.get_serializer(data=request.data)

        if serializer.is_valid():
            schedule_id = serializer.validated_data.get('schedule_id')

            try:
                schedule = Schedule.objects.get(id=schedule_id)
                schedule.delete()
                return Response({'message': '스케줄이 성공적으로 삭제되었습니다.'}, status=status.HTTP_204_NO_CONTENT)
            except Schedule.DoesNotExist:
                return Response({'error': '해당 스케줄을 찾을 수 없습니다.'}, status=status.HTTP_404_NOT_FOUND)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



class PlanViewSet(ModelViewSet):
    serializer_class = PlanModelSerializer
    queryset = Plan.objects.all()
    pagination_class = None



class ChatAPIView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        df = pd.read_csv(r"dataset.csv", encoding="cp949")
        serializer = ChatSerializer(data=request.data)

        if serializer.is_valid():
            user_input = serializer.validated_data['user_input']
            ai_response, _ = main_model.response(user_input, main_model.chat_history)

            pattern = re.findall(r'^.*?(?=1\.)', ai_response, re.DOTALL)
            if pattern:
                places = []
                for item in pattern:
                    # 이 부분에서 recommend 함수의 결과를 각 item에 대해 저장
                    place = main_model.recommend(df, user_input, main_model.korean_stop_words)
                    places.append({
                        "chat_response": item.strip(),
                        "response": place
                    })
                res = Response(places, status=status.HTTP_200_OK)
            else:
                # pattern이 없는 경우, ai_response 전체를 사용
                res = Response({"chat_response": "안녕하세요! 가볼까? 입니다."}, status=status.HTTP_200_OK)

            try:
                recommand_string = ', '.join(place)
            except UnboundLocalError:
                recommand_string = '안녕하세요! 가볼까? 입니다.'

            pattern_string = ''.join(pattern)

            ## 대화 내역 db에 저장
            chat_instance = chatDb(user_input=user_input, chat_response=pattern_string + recommand_string,
                                   user=request.user)
            chat_instance.save()

            return res

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ChatHistoryAPIView(generics.ListAPIView): # 채팅 기록 보기
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    serializer_class = ChatDbSerializer

    def get_queryset(self):
        return chatDb.objects.filter(user=self.request.user)

class DailyRecommandApiView(generics.ListAPIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    serializer_class = PlaceModelSerializer

    def get_queryset(self):
        pks = list(Place.objects.values_list('pk', flat=True).order_by('id'))
        shuffle(pks)

        # 5개의 랜덤한 pk 선택
        selected_pks = pks[:5]

        # 선택된 pk에 해당하는 Place 객체 리스트 반환
        queryset = Place.objects.filter(pk__in=selected_pks)
        return queryset
