import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/users_api.dart';

class UserManagementDashboard extends StatefulWidget {
  const UserManagementDashboard({super.key});

  @override
  _UserManagementDashboardState createState() => _UserManagementDashboardState();
}

class _UserManagementDashboardState extends State<UserManagementDashboard> {
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await fetchUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Failed to load users: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showUserForm([dynamic user]) async {
    final result = await showDialog(
      context: context,
      builder: (context) => UserFormDialog(user: user),
    );

    if (result == true) {
      _loadUsers();
    }
  }

  Future<void> _deleteUser(int id) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await deleteUser(id);
        _loadUsers();
      } catch (e) {
        _showError('Failed to delete user: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showUserForm(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      title: Text(user['email']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin: ${user['isAdmin'] == "1" ? 'Yes' : 'No'}'), // Updated to check for integer
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showUserForm(user),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => {
                              _deleteUser(int.parse(user['id'])),
                              }
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class UserFormDialog extends StatefulWidget {
  final dynamic user;

  const UserFormDialog({super.key, this.user});

  @override
  _UserFormDialogState createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  int _isAdmin = 0; // Changed to int (1 for true, 0 for false)

  @override
  void initState() {
    super.initState();
    _isAdmin = 0;
    if (widget.user != null) {
      _emailController.text = widget.user['email'];
      _isAdmin = widget.user['isAdmin'] == "1"? 1 : 0; 
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (widget.user == null) {
        await addUser(_emailController.text, _passwordController.text, _isAdmin); // Pass _isAdmin as int
      } else {
        await updateUser(
          int.parse(widget.user['id']),
          _emailController.text,
          _passwordController.text,
          _isAdmin, // Pass _isAdmin as int
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Operation failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Add User' : 'Edit User'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Invalid email format';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: widget.user == null ? 'Password' : 'New Password (optional)',
                ),
                obscureText: true,
                validator: (value) {
                  if (widget.user == null && (value == null || value.isEmpty)) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                title: const Text('Admin Privileges'),
                value: _isAdmin == 1, // Convert int to boolean for Checkbox
                onChanged: (value) {
                  setState(() {
                    _isAdmin = value == true ? 1 : 0; // Convert boolean back to int
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Save'),
        ),
      ],
    );
  }
}