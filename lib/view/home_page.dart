import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/gifts.dart';
import 'package:flutter_application_1/services/gifts_api.dart';
import 'package:flutter_application_1/view/gift_detaild_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showSearch = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Gift>> _giftsFuture;
  int _currentSlide = 0;

  final List<String> _categories = [
    'All', 'Birthday', 'Anniversary', 'Wedding', 'Christmas', 'Valentine'
  ];

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  void _loadGifts() {
    setState(() {
      _giftsFuture = _selectedCategory == 'All' 
          ? fetchGifts()
          : fetchGiftsByCategory(_selectedCategory);
    });
  }

   Widget _buildImageSlider(List<Gift> gifts) {
    final shuffledGifts = List.of(gifts)..shuffle();
    return Stack(
      children: [
        SizedBox(
          height: 200.h,  // Responsive height
          child: PageView.builder(
            itemCount: shuffledGifts.length, // Use the actual number of gifts
            onPageChanged: (index) {
              setState(() {
                _currentSlide = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _navigateToDetail(shuffledGifts[index]),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      shuffledGifts[index].image,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black54, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16.h,  // Responsive position
                      left: 16.w,
                      right: 16.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shuffledGifts[index].name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${shuffledGifts[index].price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 8.h,  // Responsive position
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(shuffledGifts.length, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: _currentSlide == index ? Colors.white : Colors.grey,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ),
      ],
    );
   }
  
  Widget _buildCategoryList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          return Padding(
            padding: EdgeInsets.all(8.w),  // Responsive padding
            child: ChoiceChip(
              label: Text(category, style: TextStyle(fontSize: 14.sp)),  // Responsive font size
              selected: _selectedCategory == category,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                  _loadGifts();
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGiftGrid(List<Gift> gifts) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
      ),
      itemCount: gifts.length,
      itemBuilder: (context, index) {
        return _buildGiftCard(gifts[index]);
      },
    );
  }

  Widget _buildGiftCard(Gift gift) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: Image.network(gift.image, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.all(8.w),  // Responsive padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gift.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),  // Responsive font size
                Text('\$${gift.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 14.sp)),  // Responsive font size
                if (gift.quantity != null)
                  Text('In Stock: ${gift.quantity}', style: TextStyle(fontSize: 12.sp)),  // Responsive font size
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(Gift gift) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => GiftDetailPage(gift: gift)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showSearch ? AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search gifts...',
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => setState(() => _showSearch = false),
          )
        ],
      ) : null,
      body: _showSearch ? _buildSearchResults() : FutureBuilder<List<Gift>>(
        future: _giftsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildImageSlider(snapshot.data!.length >= 4 
                  ? snapshot.data!.sublist(0, 4) 
                  : snapshot.data!),
                _buildCategoryList(),
                _buildGiftGrid(snapshot.data!),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        elevation: 5,
        child: Image.asset(
          'assets/logo.png',
          height: 40.h,  // Responsive height
          width: 40.w,  // Responsive width
    ),  // Responsive icon size
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: Icon(Icons.home), onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                (route) => false,
              );
          }),
          
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => setState(() => _showSearch = true),
          ),
          SizedBox(width: 40.w),  // Responsive space
          IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {}),
          IconButton(icon: Icon(Icons.person), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<Gift>>(
      future: _giftsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        final results = snapshot.data!.where((gift) =>
          gift.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
        
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(results[index].name, style: TextStyle(fontSize: 16.sp)),  // Responsive font size
            subtitle: Text('\$${results[index].price.toStringAsFixed(2)}', style: TextStyle(fontSize: 14.sp)),  // Responsive font size
            leading: Image.network(results[index].image, width: 50.w),  // Responsive image width
            onTap: () => _navigateToDetail(results[index]),
          ),
        );
      },
    );
  }
}

