<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Hash;

class DemoContentSeeder extends Seeder
{
    private const PALETTES = [
        ['#087C7C', '#53ADAE'],
        ['#0C0C0C', '#4D5454'],
        ['#53ADAE', '#0C0C0C'],
        ['#4D5454', '#087C7C'],
        ['#087C7C', '#0C0C0C'],
    ];

    private function makeSvg(string $title, int $w, int $h, int $paletteIndex, string $tag = ''): string
    {
        [$c1, $c2] = self::PALETTES[$paletteIndex % count(self::PALETTES)];
        $titleEsc = htmlspecialchars($title, ENT_QUOTES);
        $tagEsc = htmlspecialchars($tag, ENT_QUOTES);
        $fontSize = max(22, (int) ($w / 22));
        $tagFontSize = (int) ($fontSize * 0.55);
        $circleR = (int) ($h * 0.6);
        $roofX = (int) ($w / 2 - 38);
        $roofY = (int) ($h / 2 + 6);
        $titleY = (int) ($h / 2 + 82);
        $tagY = (int) ($h / 2 + 118);
        return <<<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="{$w}" height="{$h}" viewBox="0 0 {$w} {$h}">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="{$c1}"/>
      <stop offset="1" stop-color="{$c2}"/>
    </linearGradient>
  </defs>
  <rect width="{$w}" height="{$h}" fill="url(#g)"/>
  <circle cx="{$w}" cy="0" r="{$h}" fill="#ffffff" opacity="0.06"/>
  <circle cx="0" cy="{$h}" r="{$circleR}" fill="#000000" opacity="0.10"/>
  <path d="M {$roofX} {$roofY} l 38 -30 l 38 30 l -12 0 v 28 h -52 v -28 z" fill="#ffffff" opacity="0.92"/>
  <text x="50%" y="{$titleY}" font-family="Arial, Helvetica, sans-serif" font-size="{$fontSize}" font-weight="bold" fill="#ffffff" text-anchor="middle">{$titleEsc}</text>
  <text x="50%" y="{$tagY}" font-family="Arial, Helvetica, sans-serif" font-size="{$tagFontSize}" fill="#ffffff" opacity="0.85" text-anchor="middle">{$tagEsc}</text>
</svg>
SVG;
    }

    private function storeSvg(string $dir, string $filename, string $content): void
    {
        $path = public_path('images/' . $dir);
        File::ensureDirectoryExists($path);
        File::put($path . '/' . $filename, $content);
    }

    public function run(): void
    {
        if (DB::table('categories')->count() > 0) {
            return;
        }

        /* ---------- Parameters ---------- */
        $parameters = [
            ['name' => 'Chambres', 'type_of_parameter' => 'number', 'type_values' => '', 'is_required' => 1],
            ['name' => 'Salles de bain', 'type_of_parameter' => 'number', 'type_values' => '', 'is_required' => 1],
            ['name' => 'Surface (m²)', 'type_of_parameter' => 'textbox', 'type_values' => '', 'is_required' => 1],
            ['name' => 'Pièces', 'type_of_parameter' => 'number', 'type_values' => '', 'is_required' => 0],
            ['name' => 'Étage', 'type_of_parameter' => 'textbox', 'type_values' => '', 'is_required' => 0],
            ['name' => 'Meublé', 'type_of_parameter' => 'dropdown', 'type_values' => '["Oui","Non"]', 'is_required' => 0],
        ];
        foreach ($parameters as $i => $p) {
            DB::table('parameters')->insert(array_merge($p, ['created_at' => now(), 'updated_at' => now()]));
        }

        /* ---------- Categories ---------- */
        $categories = [
            ['category' => 'Appartements', 'parameter_types' => '1,2,3,4', 'sequence' => 1, 'slug_id' => '20001'],
            ['category' => 'Maisons', 'parameter_types' => '1,2,3,4,5', 'sequence' => 2, 'slug_id' => '20002'],
            ['category' => 'Villas', 'parameter_types' => '1,2,3,4,5', 'sequence' => 3, 'slug_id' => '20003'],
            ['category' => 'Terrains', 'parameter_types' => '3', 'sequence' => 4, 'slug_id' => '20004'],
            ['category' => 'Locaux commerciaux', 'parameter_types' => '1,2,3', 'sequence' => 5, 'slug_id' => '20005'],
            ['category' => 'Bureaux', 'parameter_types' => '3,4,5', 'sequence' => 6, 'slug_id' => '20006'],
        ];
        foreach ($categories as $i => $c) {
            $file = 'categorie-' . ($i + 1) . '.svg';
            $this->storeSvg('category', $file, $this->makeSvg($c['category'], 600, 400, $i, 'Immozen'));
            DB::table('categories')->insert(array_merge($c, [
                'image' => $file,
                'status' => 1,
                'meta_title' => $c['category'] . ' - Immozen',
                'meta_description' => 'Annonces de ' . strtolower($c['category']) . ' à vendre et à louer sur Immozen.',
                'meta_keywords' => strtolower($c['category']) . ', immobilier, immozen',
                'meta_image' => '',
                'created_at' => now(),
                'updated_at' => now(),
            ]));
        }

        /* ---------- Properties ---------- */
        $properties = [
            ['Appartement lumineux avec balcon', 'Paris', 'Île-de-France', 48.8566, 2.3522, 0, '659000', '', '12 rue des Lilas, 75011 Paris', 1, 3, 78, 4, '3e', 214, 0],
            ['Villa contemporaine avec piscine', 'Nice', 'Provence-Alpes-Côte d\'Azur', 43.7102, 7.2620, 0, '1290000', '', '7 chemin des Oliviers, 06000 Nice', 3, 5, 210, 7, '', 189, 1],
            ['Maison de ville rénovée', 'Lyon', 'Auvergne-Rhône-Alpes', 45.7640, 4.8357, 0, '545000', '', '24 quai Saint-Antoine, 69002 Lyon', 2, 4, 132, 6, '', 176, 0],
            ['Studio meublé proche gare', 'Lille', 'Hauts-de-France', 50.6292, 3.0573, 1, '720', 'Monthly', '5 rue de Tournai, 59000 Lille', 1, 1, 32, 1, '1er', 158, 0],
            ['Loft industriel spacieux', 'Bordeaux', 'Nouvelle-Aquitaine', 44.8378, -0.5792, 1, '1850', 'Monthly', '18 rue Notre-Dame, 33000 Bordeaux', 1, 2, 96, 4, 'RDC', 167, 1],
            ['Terrain constructible viabilisé', 'Toulouse', 'Occitanie', 43.6047, 1.4442, 0, '189000', '', 'Lotissement des Coteaux, 31200 Toulouse', 4, 0, 650, 0, '', 143, 0],
            ['Duplex avec terrasse panoramique', 'Marseille', 'Provence-Alpes-Côte d\'Azur', 43.2965, 5.3698, 0, '798000', '', '9 corniche Kennedy, 13007 Marseille', 1, 4, 118, 5, '2e', 231, 0],
            ['Bureau open-space modulable', 'Nantes', 'Pays de la Loire', 47.2184, -1.5536, 1, '2400', 'Monthly', '3 allée Baco, 44000 Nantes', 6, 0, 240, 0, '', 121, 0],
            ['Longère en pierre avec jardin', 'Rennes', 'Bretagne', 48.1173, -1.6778, 0, '432000', '', '45 route de Saint-Jacques, 35000 Rennes', 2, 4, 145, 6, '', 134, 0],
            ['Local commercial en pied d\'immeuble', 'Strasbourg', 'Grand Est', 48.5734, 7.7521, 0, '315000', '', '11 rue des Grandes Arcades, 67000 Strasbourg', 5, 0, 88, 0, '', 112, 0],
            ['Appartement familial près des plages', 'Montpellier', 'Occitanie', 43.6108, 3.8767, 1, '1290', 'Monthly', '22 avenue de la Mer, 34000 Montpellier', 1, 3, 84, 4, '1er', 149, 0],
            ['Chalet vue lac à 10 min des pistes', 'Annecy', 'Auvergne-Rhône-Alpes', 45.8992, 6.1294, 3, '985000', '', '16 route du Lac, 74000 Annecy', 3, 6, 175, 8, '', 205, 1],
        ];

        foreach ($properties as $i => $p) {
            [$title, $city, $state, $lat, $lon, $ptype, $price, $rentduration, $address, $catId, $beds, $surface, $pieces, $floor, $clicks, $premium] = $p;

            $existing = DB::table('propertys')->where('title', $title)->first();
            if ($existing) {
                continue;
            }

            $titleImage = 'bien-' . ($i + 1) . '.svg';
            $this->storeSvg('property_title_img', $titleImage, $this->makeSvg($title, 1200, 800, $i, $city));

            $id = DB::table('propertys')->insertGetId([
                'category_id' => (string) $catId,
                'package_id' => null,
                'title' => $title,
                'description' => $title . ' situé(e) à ' . $city . '. Beau volume, lumière traversée et prestations de qualité. Proche des commerces, des écoles et des transports. Contactez-nous pour organiser une visite avec Immozen.',
                'address' => $address,
                'client_address' => $address,
                'propery_type' => $ptype,
                'price' => $price,
                'post_type' => '0',
                'city' => $city,
                'country' => 'France',
                'state' => $state,
                'title_image' => $titleImage,
                'three_d_image' => '',
                'video_link' => '',
                'latitude' => $lat + 0.0015 * (($i % 5) - 2),
                'longitude' => $lon + 0.0015 * (($i % 3) - 1),
                'added_by' => 0,
                'status' => 1,
                'total_click' => $clicks,
                'rentduration' => $rentduration,
                'slug_id' => (string) (30001 + $i),
                'meta_title' => $title . ' | Immozen',
                'meta_description' => $title . ' à ' . $city . ' (' . $state . ').',
                'meta_keywords' => strtolower($city) . ', immobilier, achat, location',
                'meta_image' => '',
                'is_premium' => $premium,
                'request_status' => 'approved',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            $galleryDir = 'property_gallery_img/' . $id;
            foreach ([1, 2, 3] as $g) {
                $galleryFile = 'photo-' . $g . '.svg';
                $this->storeSvg($galleryDir, $galleryFile, $this->makeSvg($title . ' – photo ' . $g, 900, 600, $i + $g, $city));
                DB::table('property_images')->insert([
                    'propertys_id' => $id,
                    'image' => $galleryFile,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            $paramValues = [
                1 => (string) $beds,
                2 => (string) max(1, (int) round($beds / 2)),
                3 => (string) $surface,
                4 => (string) $pieces,
                5 => $floor,
                6 => $ptype == 1 ? 'Oui' : 'Non',
            ];
            foreach ($paramValues as $paramId => $value) {
                if ($value === '') {
                    continue;
                }
                if ($paramId === 4 && $pieces === 0) {
                    continue;
                }
                DB::table('assign_parameters')->insert([
                    'modal_type' => \App\Models\Property::class,
                    'modal_id' => $id,
                    'property_id' => $id,
                    'parameter_id' => $paramId,
                    'value' => $value,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }

        /* Point the default slider at the first demo property */
        DB::table('sliders')->where('default_data', 1)->update([
            'propertys_id' => 1,
            'show_property_details' => 1,
            'updated_at' => now(),
        ]);

        /* ---------- Customers ---------- */
        $customers = [
            ['Camille Dubois', 'camille.dubois@example.fr', '+33 6 12 34 56 78', '8 rue de Rivoli, 75004 Paris', 1],
            ['Lucas Martin', 'lucas.martin@example.fr', '+33 6 23 45 67 89', '14 cours Vitton, 69006 Lyon', 0],
            ['Emma Bernard', 'emma.bernard@example.fr', '+33 6 34 56 78 90', '3 la Canebière, 13001 Marseille', 1],
            ['Hugo Petit', 'hugo.petit@example.fr', '+33 6 45 67 89 01', '27 rue Sainte-Catherine, 33000 Bordeaux', 0],
            ['Chloé Durand', 'chloe.durand@example.fr', '+33 6 56 78 90 12', '5 promenade des Anglais, 06000 Nice', 0],
        ];
        foreach ($customers as $i => $c) {
            [$name, $email, $mobile, $address, $premium] = $c;
            $avatar = 'client-' . ($i + 1) . '.svg';
            $parts = preg_split('/\s+/', trim($name));
            $initials = strtoupper(substr($parts[0], 0, 1) . (isset($parts[1]) ? substr($parts[1], 0, 1) : ''));
            $this->storeSvg('users', $avatar, $this->makeSvg($initials, 300, 300, $i + 2, 'Immozen'));
            DB::table('customers')->insert([
                'name' => $name,
                'auth_id' => 'demo-uid-' . ($i + 1),
                'email' => $email,
                'mobile' => $mobile,
                'profile' => $avatar,
                'address' => $address,
                'fcm_id' => '',
                'logintype' => '3',
                'password' => Hash::make('immozen123'),
                'isActive' => 1,
                'api_token' => null,
                'notification' => 1,
                'subscription' => $premium,
                'about_me' => '',
                'is_premium' => $premium,
                'slug_id' => (string) (40001 + $i),
                'city' => '',
                'state' => '',
                'country' => 'France',
                'is_email_verified' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        /* ---------- Articles ---------- */
        $articles = [
            ['Le marché immobilier français en 2026 : tendances et perspectives', 'Les prix se stabilisent dans les grandes métropoles tandis que les villes moyennes attirent de nouveaux acheteurs. Analyse complète des dynamiques par région et conseils pour investir sereinement.'],
            ['Acheter ou louer : que choisir en 2026 ?', 'Entre taux d\'emprunt, aides au logement et évolution des modes de vie, nous comparons les deux options pour vous aider à prendre la meilleure décision selon votre situation.'],
            ['Les frais cachés à anticiper avant d\'acheter un bien immobilier', 'Notaire, copropriété, travaux, taxe foncière : faites le tour complet des coûts annexes pour éviter les mauvaises surprises le jour de la signature.'],
        ];
        foreach ($articles as $i => $a) {
            $img = 'article-' . ($i + 1) . '.svg';
            $this->storeSvg('article_img', $img, $this->makeSvg($a[0], 1000, 600, $i + 1, 'Conseils Immozen'));
            DB::table('articles')->insert([
                'title' => $a[0],
                'image' => $img,
                'description' => '<p>' . $a[1] . '</p><p>L\'équipe Immozen vous accompagne à chaque étape de votre projet immobilier, de la recherche du bien jusqu\'à la signature définitive chez le notaire.</p>',
                'category_id' => '0',
                'slug_id' => (string) (50001 + $i),
                'meta_title' => $a[0] . ' | Immozen',
                'meta_description' => $a[1],
                'meta_keywords' => 'immobilier, conseils, immozen',
                'meta_image' => '',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        /* ---------- FAQs ---------- */
        $faqs = [
            ['Comment créer un compte sur Immozen ?', 'Téléchargez l\'application, inscrivez-vous avec votre adresse e-mail ou votre numéro de téléphone, puis complétez votre profil. C\'est gratuit et cela ne prend qu\'une minute.'],
            ['Comment publier une annonce immobilière ?', 'Depuis votre profil, appuyez sur « Ajouter une propriété », renseignez les informations du bien, ajoutez vos photos et publiez. Votre annonce sera visible après validation.'],
            ['La diffusion d\'annonces est-elle payante ?', 'La création de compte est gratuite. Selon votre forfait, vous pouvez publier un nombre limité ou illimité d\'annonces et mettre en avant vos biens.'],
            ['Comment contacter un vendeur ou un propriétaire ?', 'Ouvrez la fiche du bien qui vous intéresse puis utilisez le bouton de contact pour appeler, envoyer un e-mail ou discuter directement dans la messagerie intégrée.'],
            ['Mes données personnelles sont-elles protégées ?', 'Oui. Vos données sont utilisées uniquement pour le fonctionnement du service conformément à notre politique de confidentialité et ne sont jamais revendues à des tiers.'],
        ];
        foreach ($faqs as $f) {
            DB::table('faqs')->insert([
                'question' => $f[0],
                'answer' => $f[1],
                'status' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
