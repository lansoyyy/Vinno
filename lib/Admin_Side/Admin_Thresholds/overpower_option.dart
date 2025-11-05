import 'package:flutter/material.dart';

class OverpowerSetting extends StatefulWidget {
  final void Function(bool) onPress;
  final Widget divider;
  final double cbRating; // CB rating in Amps
  final Function(double value, String action)? onChanged;

  OverpowerSetting({
    super.key,
    required this.onPress,
    required this.divider,
    this.cbRating = 20.0,
    this.onChanged,
  });

  @override
  State<OverpowerSetting> createState() => _OverpowerSettingState();
}

class _OverpowerSettingState extends State<OverpowerSetting> {
  bool isExpanded = false;
  double _overpowerValue = 4400.0; // Default: 220V * 20A = 4400W
  String _overpowerChosen = 'Trip';

  @override
  void initState() {
    super.initState();
    // Initialize with CB rating * 220V as default value
    _overpowerValue = 220.0 * widget.cbRating;
  }

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
        leading: Icon(Icons.energy_savings_leaf_outlined, size: 30),
        tilePadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overpower Settings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isExpanded ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Row(
              children: [
                Text(
                  _overpowerValue.toStringAsFixed(1),
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
              _overpowerChosen.toString(),
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
                      _overpowerValue.toStringAsFixed(1),
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
                          // Calculate max power based on CB rating (220V * CB rating)
                          final maxPower = 220.0 * widget.cbRating;
                          _overpowerValue = (_overpowerValue - 10).clamp(
                            0,
                            maxPower,
                          );
                          widget.onChanged
                              ?.call(_overpowerValue, _overpowerChosen);
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
                          value: _overpowerValue,
                          min: 0,
                          max: 220.0 * widget.cbRating,
                          divisions: (220.0 * widget.cbRating / 10).round(),
                          activeColor: Color(0xFF2ECC71),
                          inactiveColor: Colors.grey[300],
                          onChanged: (value) {
                            setState(() {
                              _overpowerValue = value;
                            });
                            widget.onChanged
                                ?.call(_overpowerValue, _overpowerChosen);
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      iconSize: 28,
                      onPressed: () {
                        setState(() {
                          // Calculate max power based on CB rating (220V * CB rating)
                          final maxPower = 220.0 * widget.cbRating;
                          _overpowerValue = (_overpowerValue + 10).clamp(
                            0,
                            maxPower,
                          );
                          widget.onChanged
                              ?.call(_overpowerValue, _overpowerChosen);
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
          selected: (_overpowerChosen == 'Off'),
          onSelected: (bool value) {
            setState(() {
              _overpowerChosen = 'Off';
            });
            widget.onChanged?.call(_overpowerValue, _overpowerChosen);
          },
          label: Text(
            'Off',
            style: TextStyle(
              color: (_overpowerChosen == 'Off') ? Colors.white : Colors.black,
              fontWeight: (_overpowerChosen == 'Off')
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
                  (_overpowerChosen == 'Alarm') ? Colors.white : Colors.black,
              fontWeight: (_overpowerChosen == 'Alarm')
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
          selected: (_overpowerChosen == 'Alarm'),
          onSelected: (bool value) {
            setState(() {
              _overpowerChosen = 'Alarm';
            });
            widget.onChanged?.call(_overpowerValue, _overpowerChosen);
          },
        ),
        ChoiceChip(
          label: Text(
            'Trip',
            style: TextStyle(
              color: (_overpowerChosen == 'Trip') ? Colors.white : Colors.black,
              fontWeight: (_overpowerChosen == 'Trip')
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
          selected: (_overpowerChosen == 'Trip'),
          onSelected: (bool value) {
            setState(() {
              _overpowerChosen = 'Trip';
            });
            widget.onChanged?.call(_overpowerValue, _overpowerChosen);
          },
        ),
      ],
    );
  }
}
