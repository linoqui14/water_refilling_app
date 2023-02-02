

import 'package:flutter/material.dart';

import '../tools/variables.dart';



class CustomTextButton extends StatelessWidget{
  const CustomTextButton(
      {
        Key? key,
        this.onPressed,
        this.text="Text Here",
        this.rTopRight=10,this.rTopLeft=10,
        this.rBottomRight=10,this.rBottomLeft=10,
        this.rAll,
        this.color=MyColors.skyBlueDead,
        this.width = 100,
        this.height = 30,
        this.padding = EdgeInsets.zero,
        this.onHold,
        this.style = const TextStyle(color: Colors.white),
        this.icon
      }) : super(key: key);

  final Function()? onPressed;
  final String text;
  final double rTopRight;
  final double rTopLeft ;
  final double rBottomRight;
  final double rBottomLeft;
  final double? rAll;
  final Color color;
  final double width;
  final double height;
  final EdgeInsets padding;
  final Function()? onHold;
  final TextStyle? style;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextButton(
        onLongPress: onHold,
        onPressed: onPressed,
        child: Container(
            height: height,
            padding: padding,
            alignment: Alignment.center,
            width: width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(icon!=null)
                  icon!,
                if(icon!=null)
                  Padding(padding: EdgeInsets.only(right: 10)),
                Text(text,style: style,),
              ],
            )
        ),
        style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            fixedSize: MaterialStateProperty.all(Size(width, height)),
            backgroundColor: MaterialStateProperty.all(color),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: rAll!=null?BorderRadius.all(Radius.circular(rAll!)):BorderRadius.only(
                      bottomRight: Radius.circular(rBottomRight),
                      bottomLeft: Radius.circular(rBottomLeft),
                      topRight: Radius.circular(rTopRight),
                      topLeft: Radius.circular(rTopLeft),
                    )

                )
            )
        )
    );
  }
}