/*
* Copyright (c) 2019 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

/**
 * IllustrativeDialog is an elementary OS styled dialog used to display a message to the user. It is more illustrative than Granite.MessageDialog, using a larger icon and more vertical layout.
 *
 * The class itself is similar to its Gtk equivalent {@link Gtk.MessageDialog}
 * but follows elementary OS design conventions.
 *
 * See [[https://elementary.io/docs/human-interface-guidelines#dialogs|The Human Interface Guidelines for dialogs]]
 * for more detailed disscussion on the dialog wording and design.
 *
 * ''Example''<<BR>>
 * {{{
 *   var message_dialog = new IllustrativeDialog.with_image_from_icon_name (
 *      "This is a primary text",
 *      "This is a secondary, multiline, long text. This text usually extends the primary text and prints e.g: the details of an error.",
 *      "applications-development",
 *      Gtk.ButtonsType.CLOSE
 *   );
 *
 *   var custom_widget = new Gtk.CheckButton.with_label ("Custom widget");
 *   custom_widget.show ();
 *
 *   message_dialog.custom_bin.add (custom_widget);
 *   message_dialog.run ();
 *   message_dialog.destroy ();
 * }}}
 *
 * {{../doc/images/IllustrativeDialog.png}}
 */
public class IllustrativeDialog : Gtk.Dialog {
    /**
     * The primary text, title of the dialog.
     */
    public string primary_text {
        get {
            return primary_label.label;
        }

        set {
            primary_label.label = value;
        }
    }

    /**
     * The secondary text, body of the dialog.
     */
    public string secondary_text {
        get {
            return secondary_label.label;
        }

        set {
            secondary_label.label = value;
        }
    }

    /**
     * The {@link GLib.Icon} that is used to display the image
     * on the left side of the dialog.
     */
    public GLib.Icon image_icon {
        owned get {
            return image.gicon;
        }

        set {
            image.set_from_gicon (value, Gtk.IconSize.INVALID);
            image.pixel_size = 64;
        }
    }

    /**
     * The {@link Gtk.Label} that displays the {@link IllustrativeDialog.primary_text}.
     *
     * Most of the times, you will only want to modify the {@link IllustrativeDialog.primary_text} string,
     * this is available to set additional properites like {@link Gtk.Label.use_markup} if you wish to do so.
     */
    public Gtk.Label primary_label { get; construct; }

    /**
     * The {@link Gtk.Label} that displays the {@link IllustrativeDialog.secondary_text}.
     *
     * Most of the times, you will only want to modify the {@link IllustrativeDialog.secondary_text} string,
     * this is available to set additional properites like {@link Gtk.Label.use_markup} if you wish to do so.
     */
    public Gtk.Label secondary_label { get; construct; }

    /**
     * The {@link Gtk.ButtonsType} value to display a set of buttons
     * in the dialog.
     *
     * By design, some actions are not acceptable and such action values will not be added to the dialog, these include:
     *
     *  * {@link Gtk.ButtonsType.OK}
     *  * {@link Gtk.ButtonsType.YES_NO}
     *  * {@link Gtk.ButtonsType.OK_CANCEL}
     *
     * If you wish to provide more specific actions for your dialog
     * pass a {@link Gtk.ButtonsType.NONE} to {@link IllustrativeDialog.IllustrativeDialog} and manually
     * add those actions with {@link Gtk.Dialog.add_buttons} or {@link Gtk.Dialog.add_action_widget}.
     */
    public Gtk.ButtonsType buttons {
        construct {
            switch (value) {
                case Gtk.ButtonsType.NONE:
                    break;
                case Gtk.ButtonsType.CLOSE:
                    add_button (_("_Close"), Gtk.ResponseType.CLOSE);
                    break;
                case Gtk.ButtonsType.CANCEL:
                    add_button (_("_Never Mind"), Gtk.ResponseType.CANCEL);
                    break;
                case Gtk.ButtonsType.OK:
                case Gtk.ButtonsType.YES_NO:
                case Gtk.ButtonsType.OK_CANCEL:
                    warning ("Unsupported GtkButtonsType value");
                    break;
                default:
                    warning ("Unknown GtkButtonsType value");
                    break;
            }
        }
    }

    /**
     * The custom area to add custom widgets.
     *
     * This bin can be used to add any custom widget to the message area such as a {@link Gtk.ComboBox} or {@link Gtk.CheckButton}.
     * Note that after adding such widget you will need to call {@link Gtk.Widget.show} or {@link Gtk.Widget.show_all} on the widget itself for it to appear in the dialog.
     *
     * If you want to add multiple widgets to this area, create a new container such as {@link Gtk.Grid} or {@link Gtk.Box} and then add it to the custom bin.
     *
     * When adding a custom widget to the custom bin, the {@link IllustrativeDialog.secondary_label}'s bottom margin will be expanded automatically
     * to compensate for the additional widget in the dialog.
     * Removing the previously added widget will remove the bottom margin.
     *
     * If you don't want to have any margin between your custom widget and the {@link IllustrativeDialog.secondary_label}, simply add your custom widget
     * and then set the {@link Gtk.Label.margin_bottom} of {@link IllustrativeDialog.secondary_label} to 0.
     */
    public Gtk.Bin custom_bin { get; construct; }

    /**
     * The image that's displayed in the dialog.
     */
    private Gtk.Image image;

    /**
     * The main grid that's used to contain all dialog widgets.
     */
    private Gtk.Grid message_grid;

    /**
     * The {@link Gtk.TextView} used to display an additional error message.
     */
    private Gtk.TextView? details_view;

    /**
     * The {@link Gtk.Expander} used to hold the error details view.
     */
    private Gtk.Expander? expander;

    /**
     * SingleWidgetBin is only used within this class for creating a Bin that
     * holds only one widget.
     */
    private class SingleWidgetBin : Gtk.Bin {}

    /**
     * Constructs a new {@link IllustrativeDialog}.
     * See {@link Gtk.Dialog} for more details.
     *
     * @param primary_text the title of the dialog
     * @param secondary_text the body of the dialog
     * @param image_icon the {@link GLib.Icon} that is displayed on the left side of the dialog
     * @param buttons the {@link Gtk.ButtonsType} value that decides what buttons to use, defaults to {@link Gtk.ButtonsType.CLOSE},
     *        see {@link IllustrativeDialog.buttons} on details and what values are accepted
     */
    public IllustrativeDialog (string primary_text, string secondary_text, GLib.Icon image_icon, Gtk.ButtonsType buttons = Gtk.ButtonsType.CLOSE) {
        Object (
            primary_text: primary_text,
            secondary_text: secondary_text,
            image_icon: image_icon,
            buttons: buttons
        );
    }

    /**
     * Constructs a new {@link IllustrativeDialog} with an icon name as it's icon displayed in the image.
     * This constructor is same as the main one but with a difference that
     * you can pass an icon name string instead of manually creating the {@link GLib.Icon}.
     *
     * The {@link IllustrativeDialog.image_icon} will store the created icon
     * so you can retrieve it later with {@link GLib.Icon.to_string}.
     *
     * See {@link Gtk.Dialog} for more details.
     *
     * @param primary_text the title of the dialog
     * @param secondary_text the body of the dialog
     * @param image_icon_name the icon name to create the dialog image with
     * @param buttons the {@link Gtk.ButtonsType} value that decides what buttons to use, defaults to {@link Gtk.ButtonsType.CLOSE},
     *        see {@link IllustrativeDialog.buttons} on details and what values are accepted
     */
    public IllustrativeDialog.with_image_from_icon_name (string primary_text, string secondary_text, string image_icon_name = "dialog-information", Gtk.ButtonsType buttons = Gtk.ButtonsType.CLOSE) {
        Object (
            primary_text: primary_text,
            secondary_text: secondary_text,
            image_icon: new ThemedIcon (image_icon_name),
            buttons: buttons
        );
    }

    construct {
        resizable = false;
        deletable = false;
        skip_taskbar_hint = true;

        image = new Gtk.Image ();
        image.valign = Gtk.Align.CENTER;

        primary_label = new Gtk.Label (null);
        primary_label.justify = Gtk.Justification.CENTER;
        primary_label.max_width_chars = 50;
        primary_label.selectable = true;
        primary_label.wrap = true;
        primary_label.get_style_context ().add_class (Granite.STYLE_CLASS_PRIMARY_LABEL);

        secondary_label = new Gtk.Label (null);
        secondary_label.justify = Gtk.Justification.CENTER;
        secondary_label.max_width_chars = 50;
        secondary_label.selectable = true;
        secondary_label.use_markup = true;
        secondary_label.wrap = true;

        custom_bin = new SingleWidgetBin ();
        custom_bin.add.connect (() => {
            secondary_label.margin_bottom = 18;
            if (expander != null) {
                custom_bin.margin_top = 6;
            }
        });

        custom_bin.remove.connect (() => {
            secondary_label.margin_bottom = 0;

            if (expander != null) {
                custom_bin.margin_top = 0;
            }
        });

        message_grid = new Gtk.Grid ();
        message_grid.column_spacing = 12;
        message_grid.margin_start = message_grid.margin_end = 12;
        message_grid.orientation = Gtk.Orientation.VERTICAL;
        message_grid.row_spacing = 6;

        message_grid.add (image);
        message_grid.add (primary_label);
        message_grid.add (secondary_label);
        message_grid.add (custom_bin);
        message_grid.show_all ();

        get_content_area ().add (message_grid);

        var action_area = get_action_area ();
        action_area.margin = 6;
        action_area.margin_top = 14;
        action_area.halign = Gtk.Align.CENTER;
    }

    /**
     * Shows a terminal-like widget for error details that can be expanded by the user.
     *
     * This method can be useful to provide the user extended error details in a
     * terminal-like text view. Calling this method will not add any widgets to the
     * {@link IllustrativeDialog.custom_bin}.
     *
     * Subsequent calls to this method will change the error message to a new one.
     *
     * @param error_message the detailed error message to display
     */
    public void show_error_details (string error_message) {
        if (details_view == null) {
            secondary_label.margin_bottom = 18;

            details_view = new Gtk.TextView ();
            details_view.border_width = 6;
            details_view.editable = false;
            details_view.pixels_below_lines = 3;
            details_view.wrap_mode = Gtk.WrapMode.WORD;
            details_view.get_style_context ().add_class (Granite.STYLE_CLASS_TERMINAL);

            var scroll_box = new Gtk.ScrolledWindow (null, null);
            scroll_box.margin_top = 12;
            scroll_box.min_content_height = 70;
            scroll_box.add (details_view);

            expander = new Gtk.Expander (_("Details"));
            expander.add (scroll_box);

            message_grid.attach (expander, 1, 2, 1, 1);
            message_grid.show_all ();

            if (custom_bin.get_child () != null) {
                custom_bin.margin_top = 12;
            }
        }

        details_view.buffer.text = error_message;
    }
}

