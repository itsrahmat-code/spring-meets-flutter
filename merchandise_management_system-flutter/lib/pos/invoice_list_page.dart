// import 'package:flutter/material.dart';
// import 'package:merchandise_management_system/models/invoice_model.dart';
// import 'package:merchandise_management_system/pages/manager_page.dart';
// import 'package:merchandise_management_system/service/invoice_service.dart';
//
// class InvoiceListPage extends StatefulWidget {
//   const InvoiceListPage({super.key});
//
//   @override
//   State<InvoiceListPage> createState() => _InvoiceListPageState();
// }
//
// enum InvoiceFilter { all, paid, unpaid }
//
// class _InvoiceListPageState extends State<InvoiceListPage> {
//   late Future<List<Invoice>> _invoicesFuture;
//   final InvoiceService _invoiceService = InvoiceService();
//   InvoiceFilter _selectedFilter = InvoiceFilter.all;
//   String _searchQuery = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchInvoices();
//   }
//
//   void _fetchInvoices() {
//     setState(() {
//       _invoicesFuture = _invoiceService.getAllInvoices();
//     });
//   }
//
//   Future<void> _refreshInvoices() async {
//     _fetchInvoices();
//   }
//
//   List<Invoice> _applyFilter(List<Invoice> invoices) {
//     List<Invoice> filtered = switch (_selectedFilter) {
//       InvoiceFilter.paid => invoices.where((i) => i.paid >= i.total).toList(),
//       InvoiceFilter.unpaid => invoices.where((i) => i.paid < i.total).toList(),
//       InvoiceFilter.all => invoices,
//     };
//
//     if (_searchQuery.isNotEmpty) {
//       filtered = filtered.where((invoice) {
//         final query = _searchQuery.toLowerCase();
//         return invoice.name.toLowerCase().contains(query) ||
//             invoice.invoiceNumber.toString().contains(query);
//       }).toList();
//     }
//
//     return filtered;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const ManagerPage(profile: {})),
//             );
//           },
//         ),
//         title: const Text('Invoices'),
//         actions: [
//           DropdownButton<InvoiceFilter>(
//             value: _selectedFilter,
//             underline: const SizedBox(),
//             icon: const Icon(Icons.filter_list, color: Colors.white),
//             dropdownColor: Colors.blue,
//             onChanged: (InvoiceFilter? newFilter) {
//               if (newFilter != null) {
//                 setState(() {
//                   _selectedFilter = newFilter;
//                 });
//               }
//             },
//             items: const [
//               DropdownMenuItem(
//                 value: InvoiceFilter.all,
//                 child: Text('All', style: TextStyle(color: Colors.white)),
//               ),
//               DropdownMenuItem(
//                 value: InvoiceFilter.paid,
//                 child: Text('Paid', style: TextStyle(color: Colors.white)),
//               ),
//               DropdownMenuItem(
//                 value: InvoiceFilter.unpaid,
//                 child: Text('Unpaid', style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _refreshInvoices,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value;
//                 });
//               },
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.search),
//                 hintText: 'Search by client or invoice number',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: FutureBuilder<List<Invoice>>(
//               future: _invoicesFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(
//                     child: Text('Error: ${snapshot.error}. Check your API URL.'),
//                   );
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text('No invoices found.'));
//                 } else {
//                   List<Invoice> filteredInvoices = _applyFilter(snapshot.data!);
//                   if (filteredInvoices.isEmpty) {
//                     return const Center(child: Text('No invoices match the filter or search.'));
//                   }
//
//                   return RefreshIndicator(
//                     onRefresh: _refreshInvoices,
//                     child: ListView.builder(
//                       itemCount: filteredInvoices.length,
//                       itemBuilder: (context, index) {
//                         Invoice invoice = filteredInvoices[index];
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           child: Card(
//                             elevation: 4,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: ListTile(
//                               contentPadding:
//                               const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                               title: Text(
//                                 'Invoice #${invoice.invoiceNumber}',
//                                 style: const TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const SizedBox(height: 4),
//                                   Text('Client: ${invoice.name}'),
//                                   Text('Total: \$${invoice.total.toStringAsFixed(2)}'),
//                                   Text('Paid: \$${invoice.paid.toStringAsFixed(2)}'),
//                                 ],
//                               ),
//                               trailing: Icon(
//                                 invoice.paid >= invoice.total
//                                     ? Icons.check_circle
//                                     : Icons.warning_amber,
//                                 color: invoice.paid >= invoice.total
//                                     ? Colors.green
//                                     : Colors.orange,
//                               ),
//                               onTap: () => _showInvoiceDetails(context, invoice),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // TODO: Navigate to a page to create a new invoice
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
//
//   void _showInvoiceDetails(BuildContext context, Invoice invoice) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Invoice Details #${invoice.invoiceNumber}'),
//         content: SingleChildScrollView(
//           child: ListBody(
//             children: <Widget>[
//               Text('Client: ${invoice.name}'),
//               Text('Email: ${invoice.email}'),
//               Text('Subtotal: \$${invoice.subtotal.toStringAsFixed(2)}'),
//               Text('Discount: \$${invoice.discount.toStringAsFixed(2)}'),
//               Text('Tax Rate: ${invoice.taxRate.toStringAsFixed(2)}%'),
//               Text('Total: \$${invoice.total.toStringAsFixed(2)}'),
//               Text('Paid: \$${invoice.paid.toStringAsFixed(2)}'),
//               const Divider(),
//               const Text('Products:', style: TextStyle(fontWeight: FontWeight.bold)),
//               ...invoice.products.map(
//                     (p) => Text('${p.name} (${p.quantity} x \$${p.price.toStringAsFixed(2)})'),
//               ),
//             ],
//           ),
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('Close'),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ],
//       ),
//     );
//   }
// }
