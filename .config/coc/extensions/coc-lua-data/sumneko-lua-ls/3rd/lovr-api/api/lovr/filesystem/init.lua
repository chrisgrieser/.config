return {
  tag = 'modules',
  summary = 'Provides access to the filesystem.',
  description = 'The `lovr.filesystem` module provides access to the filesystem.',
  notes = [[
    LÖVR programs can only write to a single directory, called the save directory.  The location of
    the save directory is platform-specific:

    <table>
      <tr>
        <td>Windows</td>
        <td><code>C:\Users\&lt;user&gt;\AppData\Roaming\LOVR\&lt;identity&gt;</code></td>
      </tr>
      <tr>
        <td>macOS</td>
        <td><code>/Users/&lt;user&gt;/Library/Application Support/LOVR/&lt;identity&gt;</code></td>
      </tr>
    </table>

    `<identity>` should be a unique identifier for your app.  It can be set either in `lovr.conf` or
    by using `lovr.filesystem.setIdentity`.

    All filenames are relative to either the save directory or the directory containing the project
    source.  Files in the save directory take precedence over files in the project.
  ]]
}
