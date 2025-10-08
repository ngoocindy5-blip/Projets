import 'package:flutter/material.dart';

// =================== Thème / Constantes ===================
const kPrimaryBlue = Color(0xFFF0F4FF);
const kAccentBlue  = Color(0xFF6B9FFF);
const kDangerRed   = Color(0xFFE53E3E);
const kWarningOrange = Color(0xFFED8936);
const kTextDark    = Color(0xFF2D3748);
const kTextLight   = Color(0xFF718096);
const kSurface     = Colors.white;
const kBorderLight = Color(0xFFE2E8F0);

const kGradientStart = Color(0xFFF8FAFF);
const kGradientEnd   = Color(0xFFEDF2FF);

class BusBreakdownReportPage extends StatefulWidget {
  const BusBreakdownReportPage({super.key});

  @override
  State<BusBreakdownReportPage> createState() => _BusBreakdownReportPageState();
}

class _BusBreakdownReportPageState extends State<BusBreakdownReportPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _matriculeCtrl = TextEditingController();
  final _chauffeurCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _lieuCtrl = TextEditingController();

  // États
  String? _typePanne;
  String? _urgence;
  bool _busImmobilise = false;
  bool _loading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  final List<String> _typesPanne = [
    'Problème moteur',
    'Panne électrique',
    'Problème de freinage',
    'Crevaison/Pneu',
    'Problème de transmission',
    'Surchauffe',
    'Panne de carburant',
    'Problème de direction',
    'Autre',
  ];

  final List<String> _niveauxUrgence = [
    'Faible',
    'Moyenne',
    'Élevée',
    'Critique',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _matriculeCtrl.dispose();
    _chauffeurCtrl.dispose();
    _descriptionCtrl.dispose();
    _lieuCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      // TODO: Implémenter la logique d'envoi
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _loading = false);
          _showSuccessDialog();
        }
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Signalement envoyé',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Votre signalement de panne a été transmis avec succès. L\'équipe technique sera notifiée.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: kTextLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetForm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Fermer',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _matriculeCtrl.clear();
    _chauffeurCtrl.clear();
    _descriptionCtrl.clear();
    _lieuCtrl.clear();
    setState(() {
      _typePanne = null;
      _urgence = null;
      _busImmobilise = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kGradientStart, kGradientEnd],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildAlertBanner(),
                        const SizedBox(height: 24),
                        _buildFormCard(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kDangerRed.withOpacity(.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.warning_rounded,
              color: kDangerRed,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signalement de Panne',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Déclarez un incident technique',
                  style: TextStyle(
                    fontSize: 13,
                    color: kTextLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: kTextLight),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWarningOrange.withOpacity(.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kWarningOrange.withOpacity(.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: kWarningOrange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Remplissez tous les champs pour un traitement rapide de votre signalement',
              style: TextStyle(
                color: kWarningOrange.withOpacity(.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informations du véhicule', Icons.directions_bus),
              const SizedBox(height: 20),

              _buildTextField(
                label: 'Matricule du bus',
                controller: _matriculeCtrl,
                hint: 'Ex: CM-2024-ABC-123',
                icon: Icons.confirmation_number_outlined,
                validator: (v) =>
                v?.isEmpty ?? true ? 'Matricule requis' : null,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                label: 'Nom du chauffeur',
                controller: _chauffeurCtrl,
                hint: 'Ex: Jean Dupont',
                icon: Icons.person_outline,
                validator: (v) =>
                v?.isEmpty ?? true ? 'Nom du chauffeur requis' : null,
              ),
              const SizedBox(height: 20),

              _buildDropdown(
                label: 'Type de panne',
                value: _typePanne,
                items: _typesPanne,
                hint: 'Sélectionnez le type',
                icon: Icons.build_outlined,
                onChanged: (v) => setState(() => _typePanne = v),
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Détails de l\'incident', Icons.description_outlined),
              const SizedBox(height: 20),

              _buildTextField(
                label: 'Lieu de la panne',
                controller: _lieuCtrl,
                hint: 'Ex: Autoroute Yaoundé-Douala, km 45',
                icon: Icons.location_on_outlined,
                validator: (v) =>
                v?.isEmpty ?? true ? 'Lieu requis' : null,
              ),
              const SizedBox(height: 20),

              _buildDropdown(
                label: 'Niveau d\'urgence',
                value: _urgence,
                items: _niveauxUrgence,
                hint: 'Évaluez l\'urgence',
                icon: Icons.priority_high,
                onChanged: (v) => setState(() => _urgence = v),
              ),
              const SizedBox(height: 20),

              _buildCheckbox(),
              const SizedBox(height: 20),

              _buildTextField(
                label: 'Description détaillée',
                controller: _descriptionCtrl,
                hint: 'Décrivez précisément le problème rencontré...',
                icon: Icons.notes,
                maxLines: 4,
                validator: (v) =>
                v?.isEmpty ?? true ? 'Description requise' : null,
              ),

              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kAccentBlue.withOpacity(.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: kAccentBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: kTextDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kTextLight.withOpacity(.6)),
            prefixIcon: Icon(icon, color: kAccentBlue, size: 20),
            filled: true,
            fillColor: kPrimaryBlue.withOpacity(.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kBorderLight, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kAccentBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kDangerRed, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: kPrimaryBlue.withOpacity(.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderLight, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, color: kAccentBlue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    hint: Text(
                      hint,
                      style: TextStyle(color: kTextLight.withOpacity(.6)),
                    ),
                    isExpanded: true,
                    items: items.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _busImmobilise
            ? kDangerRed.withOpacity(.1)
            : kPrimaryBlue.withOpacity(.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _busImmobilise
              ? kDangerRed.withOpacity(.3)
              : kBorderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _busImmobilise,
            onChanged: (v) => setState(() => _busImmobilise = v ?? false),
            activeColor: kDangerRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bus immobilisé',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Le véhicule ne peut pas continuer sa route',
                  style: TextStyle(
                    fontSize: 12,
                    color: kTextLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _loading ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: kDangerRed,
          foregroundColor: Colors.white,
          disabledBackgroundColor: kDangerRed.withOpacity(.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.send, size: 20),
            const SizedBox(width: 10),
            const Text(
              'Envoyer le signalement',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}