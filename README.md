# 🌿 Jal Media

A local social network for small villages — built with Flutter and Supabase.

Jal Media lets villagers share photos, connect with neighbors, and build a sense of community, all in a simple and lightweight mobile app.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter 3.x (Dart) |
| State Management | GetX |
| Backend | Supabase (PostgreSQL + Auth + Storage) |
| Image Loading | cached_network_image |
| Image Picking | image_picker |

---

## System Requirements

- Flutter `3.0.0` or later (tested on `3.41.6`)
- Dart `3.0.0` or later
- A [Supabase](https://supabase.com) account (free tier works)

---

## Supabase Setup

### 1. Create a Supabase project

1. Go to [app.supabase.com](https://app.supabase.com) and create a new project.
2. Note your **Project URL** and **anon/public key** (found under **Project Settings → API**).

### 2. Run the database schema

Open the **SQL Editor** in Supabase and run the following:

```sql
-- Users profile table (extends Supabase auth.users)
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  username TEXT NOT NULL UNIQUE,
  bio TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Posts
CREATE TABLE public.posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  image_url TEXT,
  caption TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Comments
CREATE TABLE public.comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Likes
CREATE TABLE public.likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);
```

### 3. Set up Row-Level Security (RLS)

```sql
-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;

-- Users: anyone can read, only own row can write
CREATE POLICY "Users are viewable by everyone" ON public.users FOR SELECT USING (true);
CREATE POLICY "Users can insert own row" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own row" ON public.users FOR UPDATE USING (auth.uid() = id);

-- Posts: public read, authenticated write own
CREATE POLICY "Posts are viewable by everyone" ON public.posts FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create posts" ON public.posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own posts" ON public.posts FOR DELETE USING (auth.uid() = user_id);

-- Comments: public read, authenticated write own
CREATE POLICY "Comments are viewable by everyone" ON public.comments FOR SELECT USING (true);
CREATE POLICY "Authenticated users can comment" ON public.comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own comments" ON public.comments FOR DELETE USING (auth.uid() = user_id);

-- Likes: public read, authenticated write own
CREATE POLICY "Likes are viewable by everyone" ON public.likes FOR SELECT USING (true);
CREATE POLICY "Authenticated users can like" ON public.likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unlike" ON public.likes FOR DELETE USING (auth.uid() = user_id);
```

### 4. Create Storage Buckets

In **Storage → New bucket**, create two **public** buckets:

| Bucket name | Public |
|---|---|
| `avatars` | ✅ Yes |
| `posts` | ✅ Yes |

Then add storage policies (SQL Editor):

```sql
-- Avatars bucket policies
CREATE POLICY "Avatar images are publicly accessible"
  ON storage.objects FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their avatar"
  ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can update their avatar"
  ON storage.objects FOR UPDATE USING (
    bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Posts bucket policies
CREATE POLICY "Post images are publicly accessible"
  ON storage.objects FOR SELECT USING (bucket_id = 'posts');

CREATE POLICY "Authenticated users can upload post images"
  ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'posts' AND auth.role() = 'authenticated'
  );
```

---

## Running the App Locally

```bash
# 1. Clone the repository
git clone https://github.com/iskero-nasoa/jal-media.git
cd jal-media

# 2. Install dependencies
flutter pub get

# 3. Add your Supabase credentials
# Edit lib/config/supabase_config.dart:
#   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
#   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

# 4. Run the app
flutter run
```

For iOS, also run:
```bash
cd ios && pod install && cd ..
```

---

## Project Structure

```
lib/
├── config/
│   └── supabase_config.dart     # Supabase URL + anon key
├── models/
│   ├── user_model.dart
│   ├── post_model.dart
│   ├── comment_model.dart
│   └── like_model.dart
├── services/
│   ├── auth_service.dart        # Sign up, sign in, sign out
│   ├── post_service.dart        # CRUD for posts + image upload
│   ├── profile_service.dart     # Profile fetch, update, avatar
│   ├── comment_service.dart     # Comments CRUD
│   └── like_service.dart        # Toggle like
├── controllers/                 # GetX controllers (state + logic)
│   ├── auth_controller.dart
│   ├── feed_controller.dart
│   ├── post_controller.dart
│   ├── profile_controller.dart
│   └── comment_controller.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   ├── home_screen.dart     # Bottom nav shell
│   │   └── feed_screen.dart     # Paginated post feed
│   ├── post/
│   │   └── create_post_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── edit_profile_screen.dart
│   └── comments/
│       └── comments_screen.dart
├── widgets/
│   ├── post_card.dart           # Post card with like/comment actions
│   ├── comment_tile.dart        # Single comment row
│   ├── avatar_widget.dart       # Cached avatar with initials fallback
│   └── loading_indicator.dart
└── main.dart                    # App entry point + theme + routing
```

---

## MVP Features

- **Authentication** — Email/password sign up & login with session persistence
- **Profile** — Avatar, username, bio; edit own profile
- **Feed** — Paginated post feed with pull-to-refresh; newest posts first
- **Post Creation** — Pick photo from gallery, add caption, publish
- **Likes** — Toggle like with optimistic UI update and live counter
- **Comments** — View, add, and delete (own) comments with author avatars

---

## Future Roadmap

- [ ] Follow / unfollow users + following-only feed
- [ ] Push notifications (new likes, comments)
- [ ] Video posts
- [ ] Stories (24-hour disappearing posts)
- [ ] Direct messaging
- [ ] Post location tagging
- [ ] Community events calendar
- [ ] Offline mode with local caching
- [ ] Admin moderation panel

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## License

MIT License — see [LICENSE](LICENSE) for details.
