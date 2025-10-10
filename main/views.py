from django.shortcuts import render, get_object_or_404
from rest_framework import status

from .models import YoutubeVideo
from rest_framework.views import APIView
from .serializer import YoutubeVideoSerializer
from rest_framework.response import Response

class YoutubeVideoAPIView(APIView):
    def get(self, request):
        output = [
            {
                "title": output.title,
                "channel": output.channel
            } for output in YoutubeVideo.objects.all()
        ]
        return Response(output)

    def post(self, request):
        serializer = YoutubeVideoSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            serializer.save()
            return Response(serializer.data)



