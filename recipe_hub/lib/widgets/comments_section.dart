import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../theme/app_theme.dart';

class CommentsSection extends StatefulWidget {
  final String recipeId;
  const CommentsSection({super.key, required this.recipeId});
  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final _ctl = TextEditingController();
  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prov = context.watch<RecipeProvider>();
    final list = prov.commentsFor(widget.recipeId);
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Comments (${list.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          if (auth.loggedIn)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: TextField(
                      controller: _ctl,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(hintText: 'Share a tip or how it turned out, ${auth.name}'))),
              const SizedBox(width: 10),
              FilledButton(
                  onPressed: () {
                    if (_ctl.text.trim().isEmpty) return;
                    prov.addComment(widget.recipeId, Comment(auth.name, _ctl.text.trim(), DateTime.now()));
                    _ctl.clear();
                  },
                  child: const Text('Post')),
            ])
          else
            Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
              const Text('Log in to leave a comment.'),
              TextButton(onPressed: () => Navigator.pushNamed(context, '/login'), child: const Text('Log in')),
              TextButton(onPressed: () => Navigator.pushNamed(context, '/signup'), child: const Text('Sign up')),
            ]),
          const SizedBox(height: 8),
          if (list.isEmpty) const Text('No comments yet. Be the first!', style: TextStyle(color: Colors.black54)),
          for (final c in list.reversed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                  backgroundColor: AppTheme.spinach.withOpacity(.12),
                  child: Text(c.author[0].toUpperCase(), style: const TextStyle(color: AppTheme.spinach))),
              title: Text(c.author, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(c.text),
            ),
        ]),
      ),
    );
  }
}
