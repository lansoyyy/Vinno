import 'package:flutter/material.dart';

class UndervoltageSetting extends StatefulWidget {
  final void Function(bool) onPress;
  final Widget divider;

  UndervoltageSetting({
    super.key,
    required this.onPress,
    required this.divider,
  });

  @override
  State<UndervoltageSetting> createState() => _UndervoltageSettingState();
}

class _UndervoltageSettingState extends State<UndervoltageSetting> {
  bool isExpanded = false;
  double _undervoltageValue = 207.0;
  String _undervoltageChosen = 'Alarm';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ExpansionTile(
        onExpansionChanged: (expanded) {
          setState(() {
            isExpanded = expanded;
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(Icons.electric_meter_outlined, size: 30),
        tilePadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),

        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Undervoltage Settings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isExpanded ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Row(
              children: [
                Text(
                  _undervoltageValue.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isExpanded ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  "V",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isExpanded ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            Text(
              _undervoltageChosen.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isExpanded ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),

        backgroundColor: Color(0xFF2ECC71),
        textColor: Colors.white,
        iconColor: Colors.white,

        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    'Threshold Setting',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),

                widget.divider,

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _undervoltageValue.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'V',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      iconSize: 28,
                      onPressed: () {
                        setState(() {
                          _undervoltageValue = (_undervoltageValue - 1).clamp(
                            0,
                            300,
                          );
                        });
                      },
                    ),

                    SizedBox(
                      width: 170,
                      child: SliderTheme(
                        data: SliderTheme.of(
                          context,
                        ).copyWith(thumbShape: SliderComponentShape.noThumb),
                        child: Slider(
                          value: _undervoltageValue,
                          min: 0,
                          max: 300,
                          divisions: 600,
                          activeColor: Color(0xFF2ECC71),
                          inactiveColor: Colors.grey[300],
                          onChanged: (value) {
                            setState(() {
                              _undervoltageValue = value;
                            });
                          },
                        ),
                      ),
                    ),

                    IconButton(
                      icon: Icon(Icons.add),
                      iconSize: 28,
                      onPressed: () {
                        setState(() {
                          _undervoltageValue = (_undervoltageValue + 1).clamp(
                            0,
                            300,
                          );
                        });
                      },
                    ),
                  ],
                ),

                SizedBox(
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black.withOpacity(0.25),
                        width: 1,
                      ),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: _filterChips(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChips() {
    return ListView(
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        ChoiceChip(
          showCheckmark: false,
          labelPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          side: BorderSide.none,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          selectedColor: Color(0xFF2ECC71),
          selected: (_undervoltageChosen == 'Off'),
          onSelected: (bool value) {
            setState(() {
              _undervoltageChosen = 'Off';
            });
          },
          label: Text(
            'Off',
            style: TextStyle(
              color:
                  (_undervoltageChosen == 'Off') ? Colors.white : Colors.black,
              fontWeight:
                  (_undervoltageChosen == 'Off')
                      ? FontWeight.w900
                      : FontWeight.normal,
            ),
          ),
        ),
        ChoiceChip(
          label: Text(
            'Alarm',
            style: TextStyle(
              color:
                  (_undervoltageChosen == 'Alarm')
                      ? Colors.white
                      : Colors.black,
              fontWeight:
                  (_undervoltageChosen == 'Alarm')
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
          showCheckmark: false,
          labelPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          side: BorderSide.none,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          selectedColor: Color(0xFF2ECC71),
          selected: (_undervoltageChosen == 'Alarm'),
          onSelected: (bool value) {
            setState(() {
              _undervoltageChosen = 'Alarm';
            });
          },
        ),
        ChoiceChip(
          label: Text(
            'Trip',
            style: TextStyle(
              color:
                  (_undervoltageChosen == 'Trip') ? Colors.white : Colors.black,
              fontWeight:
                  (_undervoltageChosen == 'Trip')
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
          showCheckmark: false,
          labelPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          side: BorderSide.none,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          selectedColor: Color(0xFF2ECC71),
          selected: (_undervoltageChosen == 'Trip'),
          onSelected: (bool value) {
            setState(() {
              _undervoltageChosen = 'Trip';
            });
          },
        ),
      ],
    );
  }
}
