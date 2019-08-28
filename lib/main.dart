import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'dart:async';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pdfa;
import 'package:path_provider/path_provider.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fname = TextEditingController();
  TextEditingController phno = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController email = TextEditingController();
  bool _autoValidate = false;
  String fullname,phnos,town,dob1,emailid;
  void _validateInputs() {
    if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
      createPdf(context);
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
  }
  createPdf(context) async{
    final font = await rootBundle.load("assets/Montserrat-Regular.ttf");
    final ttf = pdfa.Font.ttf(font);
    final pdf = pdfa.Document();
    String n=fname.text;
    String em=email.text;
    String phn=phno.text;
    String dobi=dob.text;
    String cit=city.text;
    pdf.addPage(pdfa.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        header: (pdfa.Context context) {
          if (context.pageNumber == 1) {
            return null;
          }
          return pdfa.Container(
          alignment: pdfa.Alignment.centerRight,
          margin: const pdfa.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
          padding: const pdfa.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
          decoration: const pdfa.BoxDecoration(
          border:
            pdfa.BoxBorder(bottom: true, width: 0.5, color: PdfColors.grey)),
           child: pdfa.Text('Portable Document Format',
          style: pdfa.Theme.of(context)
          .defaultTextStyle
          .copyWith(color: PdfColors.grey)));
         },
        build: (pdfa.Context context) => <pdfa.Widget>[
          pdfa.Header(
              level: 0,
              child: pdfa.Row(
                  mainAxisAlignment: pdfa.MainAxisAlignment.spaceBetween,
                  children: <pdfa.Widget>[
                    pdfa.Text('CV prototype', textScaleFactor: 2),
                  ])),
          pdfa.Container(
            padding: pdfa.EdgeInsets.only(left:10.0,top:15.0),
            child:pdfa.Text("Name: $n",style: pdfa.TextStyle(font: ttf)),
          ),
          pdfa.SizedBox(height: 10.0),
          pdfa.Container(
            padding: pdfa.EdgeInsets.only(left:10.0,top:15.0),
            child:pdfa.Text("Email: $em",style: pdfa.TextStyle(font: ttf)),
          ),
          pdfa.SizedBox(height: 10.0),
          pdfa.Container(
            padding: pdfa.EdgeInsets.only(left:10.0,top:15.0),
            child:pdfa.Text("Mobile: $phn",style: pdfa.TextStyle(font: ttf)),
          ),
          pdfa.SizedBox(height: 10.0),
          pdfa.Container(
            padding: pdfa.EdgeInsets.only(left:10.0,top:15.0),
            child:pdfa.Text("DOB: $dobi",style: pdfa.TextStyle(font: ttf)),
          ),
          pdfa.SizedBox(height: 10.0),
          pdfa.Container(
            padding: pdfa.EdgeInsets.only(left:10.0,top:15.0),
            child:pdfa.Text("City: $cit",style: pdfa.TextStyle(font: ttf)),
          ),
        ],
        )); // Page
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(pdf.save());
    await Printing.sharePdf(bytes: pdf.save(), filename: 'example.pdf');

  }
  final format = DateFormat("yyyy-MM-dd");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Details"),
        centerTitle: true,
        elevation: 5.0,
      ),
      body:ListView(children: <Widget>[Form(key:_formKey,child:Column(
          children: <Widget>[
            SizedBox(height: 20.0,),
            Padding(padding: EdgeInsets.only(top:15.0,left: 20.0,right:20.0),child:TextFormField(
              autocorrect: true,
              decoration:InputDecoration(labelText: "Full Name",enabled: true),
              keyboardType:TextInputType.text,
              controller: fname,
              validator: valName,
              onSaved: (String val) {
                fullname=val;
              },
            ),),
            SizedBox(height: 20.0,),
            Padding(padding: EdgeInsets.only(top:15.0,left: 20.0,right:20.0),child:TextFormField(
              autocorrect: true,
              decoration:InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
              controller: email,
              validator: valEmail,
              onSaved: (String val){
                emailid=val;
              },
            ),),
            SizedBox(height: 20.0,),
            Padding(padding: EdgeInsets.only(top:15.0,left: 20.0,right:20.0),child:TextFormField(
              autocorrect: true,
              decoration:InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.number,
              validator: valMob,
              controller: phno,
              onSaved: (String val){
                phnos=val;
              },
            ),),
            SizedBox(height:20.0),
            Container(
              padding: EdgeInsets.only(top:15.0,left: 20.0,right:20.0) ,
              child:DateTimeField(
              format: format,
              controller: dob,
              validator: getDob,
              decoration: InputDecoration(labelText: "Date of birth"),
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: DateTime(1999),
                    lastDate: currentValue ?? DateTime.now());
              },
              onSaved: (value){
                print(dob.text);
              } ,
            ),),
            SizedBox(height:20.0),
            Padding(padding: EdgeInsets.only(top:15.0,left: 20.0,right:20.0),child:TextFormField(
              autocorrect: true,
              controller: city,
              decoration:InputDecoration(labelText: "City"),
              keyboardType: TextInputType.text,
              validator: valCity,
              onSaved: (String val){
                town=val;
              },
            ),),
            SizedBox(height: 70.0,),
            Container(
              height: 70.0,
              width: 200.0,
              child: RaisedButton(
                color: Colors.redAccent,
                onPressed: _validateInputs,
                child: Text("Submit",style: TextStyle(fontSize: 25.0),),
              ),
            ),
          ],
        ),// This trailing comma makes auto-formatting nicer for build methods.
      ),
      ],),);
  }
  String getDob(DateTime val)
  {
    if(val!=null)
      return null;
    else
      return "Enter proper DOB.";
  }
  String valAge(String val){
    int x = int.parse(val);
    if(x>0 && x<120)
      return null;
    else
      return "Enter a valid age.";
  }
  String valName(String val){
    if(val.length < 5)
      return "Name must be minimum 5 charecters.";
    else
      return null;
  }
  String valEmail(String value){
      if (value.isEmpty) {
        // The form is empty
        return "Enter email address";
      }
      String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
          "\\@" +
          "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
          "(" +
          "\\." +
          "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
          ")+";
      RegExp regExp = new RegExp(p);

      if (regExp.hasMatch(value)) {
        // So, the email is valid
        return null;
      }

      // The pattern of the email didn't match the regex above.
      return 'Email is not valid';
  }
  String valCity(String val)
  {
    if(val!=null && val.length>3)
      return null;
    else
      return "Enter a valid city/town.";
  }
  String valMob(String val){
    if(val.length!=10)
      return "Not valid phone number(Max 10 digits).";
    else
      return null;
  }

}
