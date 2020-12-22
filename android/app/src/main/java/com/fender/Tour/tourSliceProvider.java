package com.fender.Tour;

import android.app.PendingIntent;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.core.graphics.drawable.IconCompat;
import androidx.slice.Slice;
import androidx.slice.SliceProvider;
import androidx.slice.builders.ListBuilder;
import androidx.slice.builders.ListBuilder.RowBuilder;
import androidx.slice.builders.SliceAction;

public class tourSliceProvider extends SliceProvider {
    private static final String TAG = "tourSliceProvider";
    /**
     * Instantiate any required objects. Return true if the provider was successfully created,
     * false otherwise.
     */
    @Override
    public boolean onCreateSliceProvider() {
        return true;
    }

    /**
     * Converts URL to content URI (i.e. content://com.fender.Tour...)
     */
    @Override
    @NonNull
    public Uri onMapIntentToUri(@Nullable Intent intent) {
        // Note: implementing this is only required if you plan on catching URL requests.
        // This is an example solution.
        Uri.Builder uriBuilder = new Uri.Builder().scheme(ContentResolver.SCHEME_CONTENT);
        if (intent == null) return uriBuilder.build();
        Uri data = intent.getData();
        if (data != null && data.getPath() != null) {
            String path = data.getPath().replace("/", "");
            uriBuilder = uriBuilder.path(path);
        }
        Context context = getContext();
        if (context != null) {
            uriBuilder = uriBuilder.authority(context.getPackageName());
        }
        return uriBuilder.build();
    }

    /**
     * Construct the Slice and bind data if available.
     */
    public Slice onBindSlice(Uri sliceUri) {
        Context context = getContext();
        SliceAction activityAction = createActivityAction();
        Log.e(TAG,", onBindSlice " + "sliceUri = "+ sliceUri.toString());
        if (context == null || activityAction == null) {
            return null;
        }
        String path = sliceUri.getPathSegments().get(/* index= */ 0);
                Log.e(TAG,", onBindSlice " + "path = "+ path);
        if ("/".equals(sliceUri.getPath())) {
            // Path recognized. Customize the Slice using the androidx.slice.builders API.
            // Note: ANRs and strict mode is enforced here so don't do any heavy operations.
            // Only bind data that is currently available in memory.
            return new ListBuilder(getContext(), sliceUri, ListBuilder.INFINITY)
                    .addRow(
                            new RowBuilder()
                                    .setTitle("URI found.")
                                    .setPrimaryAction(activityAction)
                    )
                    .build();
        } else {
            // Error: Path not found.
            return new ListBuilder(getContext(), sliceUri, ListBuilder.INFINITY)
                    .addRow(
                            new RowBuilder()
                                    .setTitle("URI not found.")
                                    .setPrimaryAction(activityAction)
                    )
                    .build();
        }
    }
    /*@Nullable
    @Override
    public Slice onBindSlice(Uri sliceUri) {
        String address = sliceUri.getQueryParameter("addr");
        Log.d(TAG,", onBindSlice " + "sliceUri = "+ sliceUri.toString());
        if (address == null) {
            return null;
        }
        String path = sliceUri.getPathSegments().get(*//* index= *//* 0);
        Log.d(TAG,", onBindSlice " + "path = "+ path);
        if ("settings_slice".equals(path)) {
            return createSettingSlice(sliceUri, address);
        } else if ("oobe_slice".equals(path)) {
            return createOobeReminderSlice(sliceUri, address);
        }
        return null;
    }
    @Nullable
    private Slice createOobeReminderSlice(Uri sliceUri, String address) {
        *//*if (!deviceHasGoneThroughOobe(address))*//* {
            ListBuilder listBuilder =
                    new ListBuilder(getContext(), sliceUri, ListBuilder.INFINITY);
            addOobeSlice(listBuilder, getContext(), address);
            return listBuilder.build();
        }
       // return null;
    }

    private static void addOobeSlice(
            ListBuilder listBuilder, Context context, String address) {
        listBuilder.addRow(
                createRow(
                        context,
                        R.drawable.icon_oobe,
                        R.string.title_oobe,
                        R.string.summary_oobe,
                        R.string.label_oobe,
                        createOobePendingIntent(context, address)));
    }
    private Slice createSettingSlice(Uri sliceUri, String address) {
        ListBuilder listBuilder =
                new ListBuilder(getContext(), sliceUri, ListBuilder.INFINITY);
        // TODO: Add your customized slice here.
        addRow1(listBuilder, getContext(), address);
        addRow2(listBuilder, getContext(), address);
        return listBuilder.build();
    }

    private static void addRow1(
            ListBuilder listBuilder, Context context, String address) {
        listBuilder.addRow(
                createRow(
                        context,
                        R.drawable.launch_background,
                        R.string.fp_slice_row1_title_gestures,
                        R.string.fp_slice_row1_summary_gestures,
                        R.string.fp_slice_row1_label_gestures,
                        createPendingIntent(context, address)));
    }

    private static PendingIntent createPendingIntent(Context context, String address){
        return PendingIntent.getActivities();
    }

    private static void addRow2(
            ListBuilder listBuilder, Context context, String address) {

    }
    private static RowBuilder createRow(
            Context context,
            @DrawableRes int iconId,
            @StringRes int titleId,
            @StringRes int summaryId,
            @StringRes int actionTitleId,
            PendingIntent pendingIntent) {
        SliceAction action =
                SliceAction.createDeeplink(
                        pendingIntent,
                        IconCompat.createWithResource(context, iconId),
                        ListBuilder.ICON_IMAGE,
                        context.getString(actionTitleId));
        return new RowBuilder()
                .setTitleItem(
                        IconCompat.createWithResource(context, iconId),
                        ListBuilder.ICON_IMAGE)
                .setTitle(context.getString(titleId))
                .setSubtitle(context.getString(summaryId))
                .setPrimaryAction(action);
    }*/
    private SliceAction createActivityAction() {
        //return null;
        //Instead of returning null, you should create a SliceAction. Here is an example:

        return SliceAction.create(
            PendingIntent.getActivity(
                getContext(), 0, new Intent(getContext(), MainActivity.class), 0
            ),
            IconCompat.createWithResource(getContext(), R.drawable.launch_background),
            ListBuilder.ICON_IMAGE,
            "Open Fender Tour"
        );

    }

    /**
     * Slice has been pinned to external process. Subscribe to data source if necessary.
     */
    @Override
    public void onSlicePinned(Uri sliceUri) {
        // When data is received, call context.contentResolver.notifyChange(sliceUri, null) to
        // trigger tourSliceProvider#onBindSlice(Uri) again.
    }

    /**
     * Unsubscribe from data source if necessary.
     */
    @Override
    public void onSliceUnpinned(Uri sliceUri) {
        // Remove any observers if necessary to avoid memory leaks.
    }
}
