# Copyright 2023 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Helper rules for demonstrating `py_wheel` examples"""

def _directory_writer_impl(ctx):
    output = ctx.actions.declare_directory(ctx.attr.out)

    args = ctx.actions.args()
    args.add("--output", output.path)

    for path, content in ctx.attr.files.items():
        args.add("--file={}={}".format(
            path,
            json.encode(content),
        ))

    ctx.actions.run(
        outputs = [output],
        arguments = [args],
        executable = ctx.executable._writer,
    )

    return [DefaultInfo(
        files = depset([output]),
        runfiles = ctx.runfiles(files = [output]),
    )]

directory_writer = rule(
    implementation = _directory_writer_impl,
    doc = "A rule for generating a directory with the requested content.",
    attrs = {
        "files": attr.string_dict(
            doc = "A mapping of file name to content to create relative to the generated `out` directory.",
        ),
        "out": attr.string(
            doc = "The name of the directory to create",
        ),
        "_writer": attr.label(
            executable = True,
            cfg = "exec",
            default = Label("//examples/wheel/private:directory_writer"),
        ),
    },
)
