

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tools/variables.dart';



class CustomTextField extends StatefulWidget{
  CustomTextField({
    Key? key,
    required this.hint,
    this.padding = const EdgeInsets.all(5),
    this.obscureText = false,
    this.rTopRight = 10,
    this.rTopLeft = 10,
    this.rBottomRight = 10,
    this.rBottomLeft = 10,
    this.color = MyColors.red,
    required this.controller,
    this.filled = false,
    this.icon,
    this.enable = true,
    this.readonly = false,
    this.suffix,
    this.keyBoardType,
    this.onChange,
    this.alignment,
    this.rAll,
    this.filledColor,
    this.borderWidth = 1,
    this.enableFloat = false,
    this.minLines = 1,
    this.style = const TextStyle(color: Colors.black54)
  }) : super(key: key);

  final String hint;
  EdgeInsets padding;
  TextInputType? keyBoardType;
  final Function(String)? onChange;
  IconData? icon;
  Widget? suffix;
  bool obscureText = false;
  double rTopRight;
  double rTopLeft ;
  double rBottomRight;
  double rBottomLeft;
  double? rAll;
  Color color;
  Color? filledColor;
  bool filled;
  bool enable;
  bool readonly;
  bool enableFloat = true;
  double borderWidth;
  TextEditingController controller;
  TextAlign? alignment;
  int minLines;
  TextStyle style;


  @override
  State<CustomTextField> createState() => _CustomTextFieldState();



}

class _CustomTextFieldState extends State<CustomTextField>{
  bool showObscureText = false;


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: widget.padding,
      child: TextField(
        inputFormatters: widget.keyBoardType==TextInputType.number?<TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]:<TextInputFormatter>[],
        textAlign: widget.alignment!=null?widget.alignment!:TextAlign.start,
        keyboardType: widget.keyBoardType!=null?widget.keyBoardType!:TextInputType.text,
        minLines: widget.minLines,
        maxLines: widget.obscureText?1:widget.minLines>3?widget.minLines+2:3,
        readOnly: widget.readonly,
        enabled:widget.enable,
        controller: widget.controller,
        obscureText:widget.obscureText?!showObscureText:showObscureText ,
        onChanged: widget.onChange,
        style: widget.style,
        decoration: InputDecoration(
            fillColor: widget.filledColor,

            suffixIcon: widget.obscureText? GestureDetector(
              onTap: (){
                setState(() {
                  showObscureText = showObscureText?false:true;
                });
              },
              child: Icon(!showObscureText?Icons.visibility_off:Icons.visibility,color: !showObscureText?widget.color.withAlpha(100):widget.color,),
            ):widget.suffix,
            prefixIcon: widget.obscureText?Icon(Icons.lock,color: widget.color.withAlpha(widget.enable?255:200),size: 20,):widget.icon != null?Icon(widget.icon,color: widget.color.withAlpha(widget.enable?255:200),size: 20,):null,
            filled: widget.filled,
            contentPadding: EdgeInsets.only(bottom: 0,top: 10,left: 10,right: 10),
            labelText: widget.enableFloat?widget.hint:null,
            labelStyle: TextStyle(
              color: widget.color.withAlpha(widget.enable?255:200),
              fontWeight: FontWeight.w100,
              fontSize: 12
            ),
            helperStyle:  TextStyle(
                color: widget.color.withAlpha(widget.enable?255:200),
                fontWeight: FontWeight.w100,
                fontSize: 12
            ),
            border: OutlineInputBorder(
                borderSide: BorderSide(
                    width:  widget.borderWidth,
                    color:  widget.color.withAlpha(widget.enable?255:widget.borderWidth==0?0:200)
                ),
                borderRadius: widget.rAll!=null?BorderRadius.all(Radius.circular(widget.rAll!)):BorderRadius.only(
                  bottomRight: Radius.circular(widget.rBottomRight),
                  bottomLeft: Radius.circular(widget.rBottomLeft),
                  topRight: Radius.circular(widget.rTopRight),
                  topLeft: Radius.circular(widget.rTopLeft),
                )
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: widget.borderWidth,
                    color:  widget.color.withAlpha(widget.enable?255:widget.borderWidth==0?0:200)
                ),
                borderRadius:  widget.rAll!=null?BorderRadius.all(Radius.circular(widget.rAll!)):BorderRadius.only(
                  bottomRight: Radius.circular(widget.rBottomRight),
                  bottomLeft: Radius.circular(widget.rBottomLeft),
                  topRight: Radius.circular(widget.rTopRight),
                  topLeft: Radius.circular(widget.rTopLeft),
                )
            ),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: widget.borderWidth,
                    color: widget.color.withAlpha(widget.enable?widget.borderWidth==0?0:200:255)
                ),
                borderRadius:  widget.rAll!=null?BorderRadius.all(Radius.circular(widget.rAll!)):BorderRadius.only(
                  bottomRight: Radius.circular(widget.rBottomRight),
                  bottomLeft: Radius.circular(widget.rBottomLeft),
                  topRight: Radius.circular(widget.rTopRight),
                  topLeft: Radius.circular(widget.rTopLeft),
                )
            ),
            disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: widget.borderWidth,
                    color: widget.color.withAlpha(200)
                ),
                borderRadius:  widget.rAll!=null?BorderRadius.all(Radius.circular(widget.rAll!)):BorderRadius.only(
                  bottomRight: Radius.circular(widget.rBottomRight),
                  bottomLeft: Radius.circular(widget.rBottomLeft),
                  topRight: Radius.circular(widget.rTopRight),
                  topLeft: Radius.circular(widget.rTopLeft),
                )
            ),
            hintText: widget.hint,
            hintStyle:  TextStyle(
                color: widget.color.withAlpha(widget.enable?255:200),
                fontWeight: FontWeight.w100,
                fontSize: 12
            ),
        ),
      ),
    );
  }


}