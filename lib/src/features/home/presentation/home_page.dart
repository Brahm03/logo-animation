import 'package:animation_lesson/src/core/consts/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static const double _scrollRange = 150;
  late AnimationController _alignController;
  late final Animation<AlignmentGeometry> _alignAnimation;
  final ScrollController _listviewController = ScrollController();
  bool isAtTheEnd = false;
  bool isDragging = false;
  bool isMoving = false;
  bool isAccepted = false;

  @override
  void initState() {
    super.initState();
    _alignController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _alignAnimation = Tween<AlignmentGeometry>(
            begin: Alignment.topLeft, end: Alignment.topCenter)
        .animate(
            CurvedAnimation(parent: _alignController, curve: Curves.linear));
    _listviewController.addListener(() {
      _alignController.value =
          (_listviewController.offset / _scrollRange).clamp(0.0, 1.0);
      if (_listviewController.position.pixels >=
          MediaQuery.sizeOf(context).height * 0.2) {
        isAtTheEnd = true;
        print('oxiradmiz: $isAtTheEnd');
        setState(() {});
      } else {
        isAtTheEnd = false;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _listviewController.dispose();
    _alignController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: (isAtTheEnd && !isAccepted)
          ? Draggable<String>(
              onDraggableCanceled: (velocity, offset) {
                isDragging = false;
                isMoving = false;
                setState(() {});
              },
              data: 'arrow_up',
              onDragStarted: () {
                isDragging = true;
                setState(() {});
              },
              childWhenDragging: SizedBox(),
              feedback: CircleAvatar(
                radius: 20,
                child: Icon(CupertinoIcons.arrow_up),
              ),
              child: IconButton.filled(
                  onPressed: () {
                    _listviewController.animateTo(
                      0.0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  },
                  icon: Icon(CupertinoIcons.arrow_up)),
            )
          : null,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        title: AlignTransition(
            alignment: _alignAnimation,
            child: AnimatedDefaultTextStyle(
                style: GoogleFonts.monaSans(
                    fontSize:
                        _alignAnimation.value == Alignment.topCenter ? 23 : 24,
                    fontWeight: _alignAnimation.value == Alignment.topCenter
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: AppColors.textPrimary),
                duration: Duration(seconds: 1),
                curve: Curves.ease,
                child: Text(
                  'Animation lesson',
                ))),
      ),
      body: Stack(
        children: [
          Scrollbar(
            thickness: 10,
            radius: Radius.circular(40),
            scrollbarOrientation: ScrollbarOrientation.left,
            child: ListView.builder(
                controller: _listviewController,
                itemCount: 200,
                itemBuilder: (context, index) => ListTile(
                      title: Text('Salom'),
                    )),
          ),
          isDragging
              ? Positioned(
                  top: 5,
                  right: 20,
                  child: DragTarget<String>(
                    onAcceptWithDetails: (details) {
                      isAccepted = true;
                      setState(() {});
                      _listviewController.animateTo(0.0,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease);
                      Future.delayed(Duration(milliseconds: 500)).then((v) {
                        isDragging = false;
                        isMoving = false;
                        isAccepted = false;
                        isAtTheEnd = false;
                        setState(() {});
                      });
                    },
                    onLeave: (data) {
                      isMoving = false;
                      setState(() {});
                    },
                    onMove: (details) {
                      isMoving = true;
                      setState(() {});
                    },
                    builder: (context, candidateData, rejectedData) =>
                        AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      height: 60,
                      width: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: isAccepted
                              ? AppColors.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: isMoving ? 5 : 2,
                              color: isMoving
                                  ? AppColors.primary
                                  : AppColors.textPrimary)),
                      child: isAccepted
                          ? Center(
                              child: Icon(
                              CupertinoIcons.arrow_up,
                              color: Colors.white,
                            ))
                          : null,
                    ),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
