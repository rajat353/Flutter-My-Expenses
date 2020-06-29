import 'package:scoped_model/scoped_model.dart';

import './connected_expenses.dart';

class MainModel extends Model
    with ConnectedExpensesModel, UserModel, ExpensesModel, UtilityModel {}
