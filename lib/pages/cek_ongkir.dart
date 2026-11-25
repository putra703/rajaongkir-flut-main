import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../providers/ongkir_providers.dart';
import '../models/province.dart';
import '../models/city.dart';
import '../models/cost.dart';

class CekOngkirScreen extends StatefulWidget {
  @override
  _CekOngkirScreenState createState() => _CekOngkirScreenState();
}

class _CekOngkirScreenState extends State<CekOngkirScreen> {
  final TextEditingController _weightController = TextEditingController(
    text: '1000',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OngkirProvider>().fetchProvinces();
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cek Ongkos Kirim'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<OngkirProvider>().reset();
              _weightController.text = '1000';
            },
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Consumer<OngkirProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOriginSection(provider),
                SizedBox(height: 24),
                Divider(),
                SizedBox(height: 24),
                _buildDestinationSection(provider),
                SizedBox(height: 24),
                Divider(),
                SizedBox(height: 24),
                _buildWeightAndCourier(provider),
                SizedBox(height: 24),
                _buildCheckButton(provider),
                SizedBox(height: 24),
                _buildResults(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOriginSection(OngkirProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'Dari',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 12),
        DropdownSearch<Province>(
          items: provider.provinces,
          selectedItem: provider.selectedOriginProvince,
          onChanged: provider.setOriginProvince,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: 'Provinsi Asal',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.map),
            ),
          ),
          popupProps: PopupProps.modalBottomSheet(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Cari provinsi...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            modalBottomSheetProps: ModalBottomSheetProps(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            itemBuilder: (context, item, isSelected) {
              return ListTile(title: Text(item.province), selected: isSelected);
            },
          ),
          filterFn: (item, filter) =>
              item.province.toLowerCase().contains(filter.toLowerCase()),
        ),
        SizedBox(height: 12),
        DropdownSearch<City>(
          items: provider.originCities,
          selectedItem: provider.selectedOriginCity,
          enabled: provider.originCities.isNotEmpty,
          onChanged: provider.setOriginCity,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: 'Kota Asal',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_city),
            ),
          ),
          popupProps: PopupProps.modalBottomSheet(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Cari kota...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            modalBottomSheetProps: ModalBottomSheetProps(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            itemBuilder: (context, item, isSelected) {
              return ListTile(
                title: Text(item.fullName),
                subtitle: Text('Kode Pos: ${item.zipCode}'),
                selected: isSelected,
              );
            },
            emptyBuilder: (context, searchEntry) => Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Pilih provinsi terlebih dahulu',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          filterFn: (item, filter) =>
              item.fullName.toLowerCase().contains(filter.toLowerCase()),
        ),
      ],
    );
  }

  Widget _buildDestinationSection(OngkirProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.place, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Ke',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 12),
        DropdownSearch<Province>(
          items: provider.provinces,
          selectedItem: provider.selectedDestProvince,
          onChanged: provider.setDestProvince,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: 'Provinsi Tujuan',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.map),
            ),
          ),
          popupProps: PopupProps.modalBottomSheet(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Cari provinsi...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            modalBottomSheetProps: ModalBottomSheetProps(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            itemBuilder: (context, item, isSelected) {
              return ListTile(title: Text(item.province), selected: isSelected);
            },
          ),
          filterFn: (item, filter) =>
              item.province.toLowerCase().contains(filter.toLowerCase()),
        ),
        SizedBox(height: 12),
        DropdownSearch<City>(
          items: provider.destinationCities,
          selectedItem: provider.selectedDestCity,
          enabled: provider.destinationCities.isNotEmpty,
          onChanged: provider.setDestCity,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: 'Kota Tujuan',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_city),
            ),
          ),
          popupProps: PopupProps.modalBottomSheet(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Cari kota...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            modalBottomSheetProps: ModalBottomSheetProps(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            itemBuilder: (context, item, isSelected) {
              return ListTile(
                title: Text(item.fullName),
                subtitle: Text('Kode Pos: ${item.zipCode}'),
                selected: isSelected,
              );
            },
            emptyBuilder: (context, searchEntry) => Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Pilih provinsi terlebih dahulu',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          filterFn: (item, filter) =>
              item.fullName.toLowerCase().contains(filter.toLowerCase()),
        ),
      ],
    );
  }

  Widget _buildWeightAndCourier(OngkirProvider provider) {
    return Column(
      children: [
        TextField(
          controller: _weightController,
          decoration: InputDecoration(
            labelText: 'Berat Paket (gram)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.scale),
            helperText: 'Minimal 1 gram',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final weight = int.tryParse(value) ?? 1000;
            provider.setWeight(weight);
          },
        ),
        SizedBox(height: 16),
        DropdownSearch<Courier>(
          items: provider.couriers,
          selectedItem: provider.selectedCourier,
          onChanged: provider.setCourier,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: 'Pilih Kurir',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.local_shipping),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: false,
            itemBuilder: (context, item, isSelected) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.local_shipping, color: Colors.blue),
                ),
                title: Text(item.name),
                selected: isSelected,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCheckButton(OngkirProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: provider.isLoadingCosts
            ? null
            : () async {
                final error = await provider.checkShippingCost();
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                }
              },
        icon: provider.isLoadingCosts
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(Icons.search),
        label: Text(
          provider.isLoadingCosts ? 'Mengecek...' : 'Cek Ongkir',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildResults(OngkirProvider provider) {
    if (provider.costs.isEmpty) return SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Pilih Paket Pengiriman',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Kurir: ${provider.selectedCourier?.name}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 16),

            // 🔽 Dropdown paket (kurir + service)
            DropdownSearch<ShippingCost>(
              items: provider.costs,
              selectedItem: provider.selectedCost,
              onChanged: provider.setSelectedCost,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: 'Pilih Paket',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_shipping),
                ),
              ),
              popupProps: PopupProps.modalBottomSheet(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'Cari paket (service/kurir)...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                modalBottomSheetProps: ModalBottomSheetProps(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
                itemBuilder: (context, item, isSelected) {
                  return ListTile(
                    title: Text('${item.courierName} - ${item.service}'),
                    subtitle: Text(
                      '${item.formattedPrice} • Estimasi: ${item.etd.isEmpty ? '-' : item.etd}',
                    ),
                    selected: isSelected,
                  );
                },
              ),
              filterFn: (item, filter) =>
                  item.label.toLowerCase().contains(filter.toLowerCase()),
            ),

            SizedBox(height: 16),
            if (provider.selectedCost != null) ...[
              Divider(height: 24),
              Text(
                'Detail Paket Terpilih',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${provider.selectedCost!.courierName} - ${provider.selectedCost!.service}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      provider.selectedCost!.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Biaya: ${provider.selectedCost!.formattedPrice}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Estimasi: ${provider.selectedCost!.etd.isEmpty ? '-' : provider.selectedCost!.etd}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
