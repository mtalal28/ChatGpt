import 'package:flutter/cupertino.dart';
import 'package:signin_signup/api.dart';

import '../model.dart';


class ModelsProvider with ChangeNotifier
{

String  currentModel = "gpt-3.5-turbo-0301";

String get getCurrentModel{
  return currentModel;
}
void setCurrentModel(String newModel)
{
  currentModel=newModel;
  notifyListeners();
}
List<Model>modelsList=[];
List<Model> get getModelsList{
  return modelsList;
}


Future<List<Model>> getAllModels () async{
  modelsList = await Api.getModels();
  return modelsList;

}
}